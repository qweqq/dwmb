#include "simple_uart.h"

void uart_init() {
	// set BAUD rate
	UBRRL = UBRRVAL;       //low byte
	UBRRH = (UBRRVAL >> 8); //high byte

	// set data frame format:
    // asynchronous mode,no parity, 1 stop bit, 8 bit size

	UCSRC= (1 << URSEL) | (0 << UMSEL) | (0 << UPM1) | (0 <<UPM0) |
	       (0 << USBS) | (0 << UCSZ2) | (1 << UCSZ1) | (1 << UCSZ0);

	//enable transmitter and receiver
	UCSRB = (1 << RXEN) | (1 << TXEN);
}

void uart_enable_interrupt() {
    UCSRB |= (1 << RXCIE);
}

void uart_write_byte(char c) {
	// wait if a byte is being transmitted
	while ((UCSRA & (1 << UDRE)) == 0);

	// transmit data
	UDR = c;
}

inline uint8_t uart_byte_available() {
	return ((UCSRA & (1 << RXC)) != 0);
}

char uart_read_byte() {
	 // wait until a byte has been received
	while (!uart_byte_available());

	// return received data
	return UDR;
}

void uart_read_line(char* str, const uint16_t max_size) {
    char* c;
    for (c = str; (c < str + max_size - 1) && (*c != '\n'); ++c) {
        *c = uart_read_byte();
    }
    *c = '\0';
}

void uart_write_string(char* str) {
    char* c;
    for (c = str; *c != '\0'; c++) {
        uart_write_byte(*c);
    }
}

void uart_write_newline() {
    uart_write_byte('\n');
}
