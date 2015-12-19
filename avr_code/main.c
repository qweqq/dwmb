#include "hardware.h"

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "lcd_2_16.h"
#include "simple_uart.h"
#include "text.h"
#include "leds.h"
#include "adc_values.h"

static inline void adc_init()
{
    // Internal ref equal to AVCC, no left align, ADC0 input
    ADMUX = (1<<REFS0) | (0<<REFS1) | (0<<ADLAR);

    // Enable ADC and ADC interrupt
    ADCSRA = (1<<ADEN) | (1<<ADIE)
        | (1<<ADPS0) | (1<<ADPS1) | (1<<ADPS2); // F_CPU/128
}

static inline void adc_start()
{
    ADCSRA |= (1<<ADSC);
}
typedef enum {
    unplugged,
    plugged
} state_t;

state_t states[8];
uint8_t current_state;


void state_changed() {
    uart_write_byte('s');
    for (uint8_t i = 0; i < 8; i++) {
        if (states[i] == plugged) {
            uart_write_byte('p');
            continue;
        }
        if (states[i] == unplugged) {
            uart_write_byte('u');
            continue;
        }
    }
    uart_write_newline();
}

ISR(ADC_vect) {
    if (states[current_state] == plugged) {
        if (ADC > ADC_PLUGGED_LOW && ADC < ADC_PLUGGED_HIGH) {
            return;
        }
        states[current_state] = unplugged;
        state_changed();
        return;
    }
    if (states[current_state] == unplugged) {
        if (ADC > ADC_PLUGGED_LOW && ADC < ADC_PLUGGED_HIGH) {
            states[current_state] = plugged;
            state_changed();
            return;
        }
        return;
    }
}

void next_slot() {
    current_state = (current_state + 1) % 8;
    ADC_MULTIPLEXER_port |= current_state << ADC_MULTIPLEXER_shift;
    ADC_MULTIPLEXER_port &= (~ADC_MULTIPLEXER_mask) | (current_state << ADC_MULTIPLEXER_shift);
}

char c;

ISR(USART_RXC_vect) {
    c = uart_read_byte();
}

static inline void lcd_on() {
    lcd_init();
    setbit(LCD_BACKLIGHT_port, LCD_BACKLIGHT_pin);
}

static inline void lcd_off() {
    lcd_clear();
    clearbit(LCD_BACKLIGHT_port, LCD_BACKLIGHT_pin);
}

static inline void timer_init() {
    TCCR0 = (1 << CS01) | (1 << CS00);  // clock / 64: for a 14.7456MHz crystal
                                        // this gives overflow at 900Hz
    TIMSK |= (1 << TOIE0);              // enable timer0 overflow interrupt
}

ISR(TIMER0_OVF_vect) {
    update_leds();
}

static inline void init() {
    DDRB = DDRB_STATE;
    DDRC = DDRC_STATE;
    DDRD = DDRD_STATE;

    DDRD = ~0x01;    // all outputs
    DDRB = 0x07;
    DDRC = ~0x01;

    lcd_on();
    adc_init();
    uart_init();
    uart_enable_interrupt();
    timer_init();
    sei();
}


int main()
{
    _delay_ms(2500);
    init();
    leds[3] = green;
    leds[4] = yellow;
    for (;;) {
        next_slot();
        _delay_ms(50);
        uart_write_string("a\n");
        adc_start();
        _delay_ms(50);
    }
    return 0;
}
