#pragma once

#define F_CPU 14745600ul

#define BAUDRATE 115200

#define LCD_E_port PORTD
#define LCD_E_pin 6

#define LCD_RS_port PORTD
#define LCD_RS_pin 5

#define LCD_D4_port PORTD
#define LCD_D4_pin 7

#define LCD_D5_port PORTB
#define LCD_D5_pin 0

#define LCD_D6_port PORTB
#define LCD_D6_pin 2

#define LCD_D7_port PORTB
#define LCD_D7_pin 1

#define LCD_BACKLIGHT_port PORTD
#define LCD_BACKLIGHT_pin 4


#define ADC_MULTIPLEXER_port PORTC
#define ADC_MULTIPLEXER_shift 1


#define LED_COUNTER_RESET_port PORTD
#define LED_COUNTER_RESET_pin 2

#define LED_COUNTER_CLOCK_port PORTD
#define LED_COUNTER_CLOCK_pin 3

#define LED_RED_ANODE_port PORTC
#define LED_RED_ANODE_pin 4

#define LED_GREEN_ANODE_port PORTC
#define LED_GREEN_ANODE_pin 5


#define BUTTON_INPUT_port PORTB
#define BUTTON_INPUT_pin 5

// 1 - out, 0 - in   v bits v
//                   76543210
#define DDRB_STATE 0b00000111
#define DDRC_STATE 0b00111110
#define DDRD_STATE 0b11111110
