#include <avr/io.h>

#include "bit_operations.h"
#include "hardware.h"

#include "leds.h"

led_colour leds[8];

void update_leds() {
    static uint8_t led_index = 7;

    if (bitset(LED_COUNTER_CLOCK_port, LED_COUNTER_CLOCK_pin)) {
        // do a "falling edge"
        clearbit(LED_COUNTER_CLOCK_port, LED_COUNTER_CLOCK_pin);
        clearbit(LED_COUNTER_RESET_port, LED_COUNTER_RESET_pin);
    } else {
        // turn off the leds
        setbit(LED_RED_ANODE_port, LED_RED_ANODE_pin);
        setbit(LED_GREEN_ANODE_port, LED_GREEN_ANODE_pin);

        if (++led_index > 7) {
            led_index = 0;
            setbit(LED_COUNTER_RESET_port, LED_COUNTER_RESET_pin);
        }

        // do a "rising edge"
        setbit(LED_COUNTER_CLOCK_port, LED_COUNTER_CLOCK_pin);

        // set the current led to "0" if it's supposed to be on (PNP)
        setbitval(LED_GREEN_ANODE_port, LED_GREEN_ANODE_pin, 
                  !(leds[led_index] & green));

        setbitval(LED_RED_ANODE_port, LED_RED_ANODE_pin, 
                  !(leds[led_index] & red));
    }
}
