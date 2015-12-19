#include "lcd_2_16.h"

void lcd_strobe() {
    setbit(LCD_E_port, LCD_E_pin);
    _delay_ms(1);
    clearbit(LCD_E_port, LCD_E_pin);
    _delay_ms(1);
}

void lcd_write(char c) {
    setbitval(LCD_D4_port, LCD_D4_pin, c & 0x10);
    setbitval(LCD_D5_port, LCD_D5_pin, c & 0x20);
    setbitval(LCD_D6_port, LCD_D6_pin, c & 0x40);
    setbitval(LCD_D7_port, LCD_D7_pin, c & 0x80);
    lcd_strobe();
    setbitval(LCD_D4_port, LCD_D4_pin, c & 0x01)
    setbitval(LCD_D5_port, LCD_D5_pin, c & 0x02)
    setbitval(LCD_D6_port, LCD_D6_pin, c & 0x04)
    setbitval(LCD_D7_port, LCD_D7_pin, c & 0x08)
    lcd_strobe();
}

void lcd_putchar(char c) {
    setbit(LCD_RS_port,LCD_RS_pin);;
    lcd_write(c);
}

void lcd_cmd(char c) {
    clearbit(LCD_RS_port,LCD_RS_pin);
    lcd_write(c);
    _delay_ms(5);
}

void lcd_clear() {
    clearbit(LCD_RS_port,LCD_RS_pin);
    lcd_write(0x01);
    _delay_ms(5);
}

void lcd_putsp(const char *progmem_s)  {
    register char c;

    while((c = pgm_read_byte(progmem_s++)) ) {
        lcd_putchar(c);
    }

}

void lcd_putspxy(uint8_t x, uint8_t y, const char *progmem_s) {
    lcd_gotoxy(x,y);
    lcd_putsp(progmem_s);
}

void lcd_puts(char *str) {
    while(*str) lcd_putchar(*str++);
}


void lcd_putsxy(uint8_t x, uint8_t y, char *s)
{
    lcd_gotoxy(x,y);
    lcd_puts(s);
}


void lcd_gotoxy(uint8_t x, uint8_t y) {
    uint8_t offset;
    if (y==0) offset = 0x80;
    if (y==1) offset = 0xc0;

    lcd_cmd(offset+x);
}

// create a custom character
void define_char(const uint8_t pc[8], uint8_t char_code) { 
    uint8_t i;

    lcd_cmd(CGRAM | (char_code<<3)); 
    for(i=0; i<8; i++) lcd_putchar(*pc++); 
}

void lcd_init() {
    clearbit(LCD_E_port, LCD_E_pin);
#ifdef LCD_RW_port
    clearbit(LCD_RW_port,LCD_RW_pin);   // write mode
#endif
    clearbit(LCD_RS_port,LCD_RS_pin);

    _delay_ms(40);

    clearbit(LCD_D7_port,LCD_D7_pin);
    clearbit(LCD_D6_port,LCD_D6_pin);
    setbit (LCD_D5_port,LCD_D5_pin);
    setbit (LCD_D4_port,LCD_D4_pin);    // 0b0011

    lcd_strobe();                       // send it 3 times
    _delay_ms(5);
    lcd_strobe();
    _delay_ms(5);
    lcd_strobe();
    _delay_ms(5);

    clearbit(LCD_D4_port,LCD_D4_pin);       // 0b0010
    lcd_strobe();
    _delay_ms(1);

    lcd_cmd(0x28);
    lcd_cmd(0x01);
    lcd_cmd(0x0C);
} 
