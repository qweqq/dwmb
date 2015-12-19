#pragma once
#include "hardware.h"
#include "bit_operations.h"
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <string.h>
#include <util/delay.h>

#define CGRAM 0x40  // AC in CGRAM=0

void lcd_init();       
void lcd_putchar(char c);              
void lcd_gotoxy(uint8_t x, uint8_t y); 
void lcd_clear();
void lcd_puts(char* str);
void lcd_putsxy(uint8_t x, uint8_t y, char *s);

// read string from program memory
void lcd_putsp(const char *progmem_s);
void lcd_putspxy(uint8_t x, uint8_t y, const char *progmem_s);

// define custom character at the specified code
void define_char(const uint8_t pc[8], uint8_t char_code);
