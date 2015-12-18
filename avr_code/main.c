#include "hardware.h"

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

static inline void init()
// main init
{
    DDRD = ~0x01;
    DDRB = 0x07;
    DDRC = ~0x01;
    sei();
}


int main()
{
    _delay_ms(500);
    init();
    for (;;) {
    }
    return 0;
}
