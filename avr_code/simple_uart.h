#pragma once

#include "hardware.h"

#define UBRRVAL ((F_CPU/(BAUDRATE*16UL))-1)

#include <stdint.h>
#include <avr/io.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

void uart_init();
void uart_enable_interrupt();
void uart_write_byte(char c);
uint8_t uart_byte_available();
char uart_read_byte();
void uart_read_line(char* str, const uint16_t max_size);
void uart_write_string(char* str);
void uart_write_newline();
