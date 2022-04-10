#pragma once

#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include "debug.h"
#include <string.h>

// Number of decimals used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_DECIMAL WEI_TO_ETHER
#define ETH_DECIMAL WEI_TO_ETHE

// Number of selectors defined in this plugin. Should match the enum `selector_t`.
#define NUM_SELECTORS 6

#define NULL_ADDRESS "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

// Enumeration of the different selectors possible.
// Should follow the exact same order as the array declared in main.c
typedef enum
{
    CREATE,
    PROCESS_INPUT_ORDERS,
    PROCESS_OUTPUT_ORDERS,
    DESTROY,
    RELEASE_TOKENS,
    TRANSFER_FROM,

} selector_t;

extern const uint32_t NESTED_SELECTORS[NUM_SELECTORS];

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
    BOO__OUTPUTTOKEN,
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
    DESTROY__TOKEN_ID,
    DESTROY__BUY_TOKEN,
    DESTROY__OFFSET_ORDERS,
    DESTROY__LEN_ORDERS,
    DESTROY__ORDERS, // will not be reached
} destroy_parameter;

typedef enum
{
    CREATE__TOKEN_ID,
    CREATE__OFFSET_BIO,
    CREATE__LEN_BIO,
    CREATE__OFFSET_ARRAY_BIO,
    CREATE__BIO, // will not be reached
} create_parameter;

/* FeeSplitter Functions */

typedef enum
{
    RELEASE_OFFSET_TOKENS,
    RELEASE_LEN_TOKENS,
    RELEASE_ARRAY_TOKENS,
} release_tokens_paramter;

// Booleans
#define IS_COPY (1)
#define TOKEN1_FOUND (1 << 2)
#define TOKEN2_FOUND (1 << 3)
#define IS_FROM_RESERVE (1 << 4)
#define BOOL5 (1 << 5)
#define BOOL6 (1 << 6)
#define BOOL7 (1 << 7)
#define BOOL8 (1 << 8)

//screen array correspondance
//#define FIRST_SCREEN_UI 1 // Must remain first screen in screen array and always up. Comes after ID screen in handle_query_contract_ui.c
//#define SCREEN_2_UI (1 << 1)
//#define SCREEN_3_UI (1 << 2)
//#define SCREEN_4_UI (1 << 3)
//#define SCREEN_5_UI (1 << 4)
//#define SCREEN_6_UI (1 << 5)
//#define SCREEN_7_UI (1 << 6)
//#define SCREEN_8_UI (1 << 7)
//#define LAST_UI (1 << 7) // Must remain last screen in screen array.
//
//#define RIGHT_SCROLL 1
//#define LEFT_SCROLL 0

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
typedef struct __attribute__((__packed__)) context_t
{
    uint8_t on_struct;                      // 1
    uint8_t beneficiary[ADDRESS_LENGTH];    // 20
    uint8_t next_param;                     // 1
    uint8_t screen_array;                   // 1
    uint8_t previous_screen_index;          // 1
    uint8_t plugin_screen_index;            // 1
    uint32_t current_tuple_offset;          // 4
    uint32_t next_offset;                   // 4
    uint16_t current_length;                // 2
    uint16_t current_length_lvl1;           // 2
    uint8_t token1_address[ADDRESS_LENGTH]; // 20
    uint8_t token1_amount[INT256_LENGTH];   // 32
    uint8_t token1_decimals;                // 1
    char token1_ticker[MAX_TICKER_LEN];     // 12
    uint8_t token2_address[ADDRESS_LENGTH]; // 20
    char token2_ticker[MAX_TICKER_LEN];     // 12
    uint16_t offsets_lvl0[2];               // 4
    uint16_t offsets_lvl1[2];               // 4
    uint8_t length_offset_array;            // 1
    uint8_t booleans;                       // 1
    uint8_t number_of_tokens;               // 1
    selector_t selectorIndex;               // 1
} context_t;
// 160
// 12 + 16 + 60 + 32 + 24 = 144

// Piece of code that will check that the above structure is not bigger than 5 * 32. Do not remove
// this check.
_Static_assert(sizeof(context_t) <= 5 * 32, "Structure of parameters too big.");

void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_init_contract(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);

void parse_order(ethPluginProvideParameter_t *msg, context_t *context);
void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context);
void parse_batched_output_orders(ethPluginProvideParameter_t *msg, context_t *context);

void copy_offset(ethPluginProvideParameter_t *msg, context_t *context);