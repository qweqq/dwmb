#pragma once

typedef enum {
    off = 0x00,
    green = 0x01,
    red = 0x02, 
    yellow = 0x03
} led_colour;

extern led_colour leds[8];

void update_leds();
