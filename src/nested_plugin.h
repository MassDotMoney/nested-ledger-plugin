#pragma once

#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include <string.h>

// Number of selectors defined in this plugin. Should match the enum `selector_t`.
// EDIT THIS: Put in the number of selectors your plugin is going to support.
#define NUM_SELECTORS 1

// Enumeration of the different selectors possible.
// Should follow the exact same order as the array declared in main.c
// EDIT THIS: Change the naming (`selector_t`), and add your selector names.
typedef enum
{
    CREATE,
} selector_t;

/*
    INestedFactory Structs
*/

typedef enum
{
    ORDER__OPERATOR,
    ORDER__TOKEN_ADDRESS,
    ORDER__OFFSET_CALLDATA,
    ORDER__LEN_CALLDATA,
    ORDER__CALLDATA,
} order;

typedef enum
{
    BIO__INPUTTOKEN,
    BIO__AMOUNT,
    BIO__OFFSET_ORDERS,
    BIO__FROM_RESERVE,
    BIO__LEN_ORDERS,
    BIO__OFFSET_ARRAY_ORDERS
} batch_input_orders;

typedef enum
{
    BOO__INPUTTOKEN,
    BOO__OFFSET_AMOUNTS,
    BOO__OFFSET_ORDERS,
    BOO__FROM_RESERVE,
    BOO__LEN_AMOUNTS,
    BOO__AMOUNT,
    BOO__LEN_ORDERS,
    BOO__OFFSET_ARRAY_ORDERS
} batch_output_orders;

/* Parsing */

typedef enum
{
    S_NONE,
    S_BATCHED_INPUT_ORDERS,
    S_BATCHED_OUTPUT_ORDERS,
    S_ORDER,
} on_struct;

/* INestedFactory Functions */

typedef enum
{
    CREATE__A_NOOP,
    CREATE__TOKEN_ID,
    CREATE__OFFSET_BATCHINPUTORDER,
    CREATE__LEN_BATCHINPUTORDER,
    CREATE__OFFSET_ARRAY_BATCHINPUTORDER,
    CREATE__BATCH_INPUT_ORDERS,
} create_parameter;

// EDIT THIS: Rename `BOILERPLATE` to be the same as the one initialized in `main.c`.
extern const uint32_t NESTED_SELECTORS[NUM_SELECTORS];

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
// EDIT THIS: This struct is used by your plugin to save the parameters you parse. You
// will need to adapt this struct to your plugin.
typedef struct context_t
{
    uint8_t on_struct;

    // For display.
    uint8_t amount_received[INT256_LENGTH];
    uint8_t beneficiary[ADDRESS_LENGTH];
    uint8_t token_received[ADDRESS_LENGTH];
    char ticker[MAX_TICKER_LEN];
    uint8_t decimals;
    uint8_t token_found;

    // For parsing data.
    uint8_t next_param; // Set to be the next param we expect to parse.
    uint32_t offset;    // Offset at which the array or struct starts.
    bool go_to_offset;  // If set, will force the parsing to iterate through parameters until
                        // `offset` is reached.

    uint32_t current_tuple_offset;

    uint32_t next_offset;
    uint16_t current_length;

    uint16_t offsets_lvl0[2];
    uint16_t offsets_lvl1[2];
    uint8_t length_offset_array;

    // For both parsing and display.
    selector_t selectorIndex;
} context_t;

// Piece of code that will check that the above structure is not bigger than 5 * 32. Do not remove
// this check.
_Static_assert(sizeof(context_t) <= 5 * 32, "Structure of parameters too big.");

void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_init_contract(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);