#include "text.h"

void itoan(uint16_t i, char *str) {
    if (i == 0) {
        str[0] = '0';
        return;
    }
    uint8_t index = 0;
    uint16_t j = i;
    while (i != 0) {
        i /= 10;
        ++index;
    }

    str[index] = '\0';
    while (j != 0) {
        str[index - 1] = '0' + (j % 10);
        j /= 10;
        --index;
    }
}

