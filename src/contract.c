#include <stdint.h>
#include "nested_plugin.h"

// List of selectors supported by this plugin.
static const uint32_t CREATE_SELECTOR = 0xa378534b;
static const uint32_t PROCESS_INPUT_ORDERS_SELECTOR = 0x90e1aa69;
static const uint32_t PROCESS_OUTPUT_ORDERS_SELECTOR = 0x51227094;
static const uint32_t DESTROY_SELECTOR = 0xbba9b10c;
static const uint32_t RELEASE_TOKENS_SELECTOR = 0x6d9634b7;
static const uint32_t TRANSFER_FROM_SELECTOR = 0x23b872dd;

// Array of all the different plugin selectors. Make sure this follows the same
// order as the enum defined in `nested_plugin.h`
const uint32_t NESTED_SELECTORS[NUM_SELECTORS] = {
    CREATE_SELECTOR,
    PROCESS_INPUT_ORDERS_SELECTOR,
    PROCESS_OUTPUT_ORDERS_SELECTOR,
    DESTROY_SELECTOR,
    RELEASE_TOKENS_SELECTOR,
    TRANSFER_FROM_SELECTOR,
};
