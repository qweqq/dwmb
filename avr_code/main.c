#include "hardware.h"

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "lcd_2_16.h"
#include "simple_uart.h"
#include "text.h"
#include "leds.h"

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

ISR(ADC_vect) {
    char str[15];
    itoan(ADC, str);
    lcd_puts(str);
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
    uint8_t number = 0;
    char str[5];
    c = ' ';
    leds[3] = green;
    leds[4] = yellow;
    for (;;) {
        uart_write_string("foo");
        uart_write_newline();
        lcd_clear();
        lcd_puts("last char: ");
        lcd_putchar(c);
        lcd_gotoxy(0, 1);
        lcd_puts("ADC ");
        PORTC = number << 1;
        number = (number + 1) % 8;
        itoan(number, str);
        lcd_puts(str);
        lcd_puts(": ");
        _delay_ms(500);
        adc_start();
        _delay_ms(1500);
    }
    return 0;
}
