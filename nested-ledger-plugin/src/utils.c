#include "nested_plugin.h"

static const char G_HEX[] = {
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
};

void print_bytes(const uint8_t *bytes, uint16_t len) {
    unsigned char nibble1, nibble2;
    char str[] = {0, 0, 0};

    for (uint16_t count = 0; count < len; count++) {
        nibble1 = (bytes[count] >> 4) & 0xF;
        nibble2 = bytes[count] & 0xF;
        str[0] = G_HEX[nibble1];
        str[1] = G_HEX[nibble2];
        PRINTF("%s", str);
        PRINTF(" ");
    }
    PRINTF("\n");
}
