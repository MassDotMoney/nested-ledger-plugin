#pragma once

#include "debug.h"
#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

// Number of decimals used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_DECIMAL WEI_TO_ETHER
#define ETH_DECIMAL     WEI_TO_ETHER

// Network tickers
#define MATIC  "MATIC"
#define WMATIC "WMATIC"
#define AVAX   "AVAX"
#define WAVAX  "WAVAX"
#define BNB    "BNB"
#define WBNB   "WBNB"
#define ETH    "ETH"
#define WETH   "WETH"

// Utility addresses checking
#define NULL_ADDRESS "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
// Nested uses `0xeeeee` as a dummy address to represent network ticker.
#define NETWORK_TOKEN_ADDRESS \
    "\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee\xee"
#define ADDRESS_IS_NETWORK_TOKEN(_addr) (!memcmp(_addr, NETWORK_TOKEN_ADDRESS, ADDRESS_LENGTH))
#define ADDRESS_IS_NULL_ADDRESS(_addr)  (!memcmp(_addr, NULL_ADDRESS, ADDRESS_LENGTH))

// Enumeration of the different selectors possible.
// Should follow the exact same order as the array declared in main.c
typedef enum {
    CREATE,
    PROCESS_INPUT_ORDERS,
    PROCESS_OUTPUT_ORDERS,
    DESTROY,
    RELEASE_TOKENS,
    TRANSFER_FROM,
} selector_t;

// Number of selectors defined in this plugin. Should match the enum
// `selector_t`.
#define NUM_SELECTORS 6

extern const uint32_t NESTED_SELECTORS[NUM_SELECTORS];

/*
 *  ui_selector is the value send by Nested's front, which determine screen's display (ID and UI).
 *  Only the methods processInputOrder and processOutputOrder are affected by this selector.
 *
 *  ADD   => "Buy" + add_tokens_ui
 *  DEPOSIT => "Simple Deposit" + deposit_ui
 *  SYNC  => synchronization_ui
 *  Sell  => "Sell" + sell_tokens_ui
 *  WITHDRAW  => "Simple Withdraw" + withdraw_ui
 *  SWAP  => "Convert" + swap_ui
 *  EDIT_ALLOC  => edit_allocations_ui
 *  PROPO_WITHDRAWAL  => "Proportional Withdrawal" + withdraw_ui
 *  PROPO_DEPOSIT => "Proportional Deposit" + deposit_ui
 *  NOOP  => (CREATE, COPY) send but unused
 *  BURN  => "Sell all Portfolio"
 *  SEND  => send but unused
 */
typedef enum {
    NONE,
    ADD,
    DEPOSIT,
    SYNC,
    SELL,
    WITHDRAW,
    SWAP,
    EDIT_ALLOC,
    PROPO_WITHDRAWAL,
    PROPO_DEPOSIT,
    NOOP,
    BURN,
    SEND,
} ui_selector;

/*
    INestedFactory Structs
*/

typedef enum {
    ORDER__OPERATOR,
    ORDER__TOKEN_ADDRESS,
    ORDER__OFFSET_CALLDATA,
    ORDER__LEN_CALLDATA,
    ORDER__CALLDATA,
    ORDER__NOOP,
} order;

typedef enum {
    BIO__INPUTTOKEN,
    BIO__AMOUNT,
    BIO__OFFSET_ORDERS,
    BIO__FROM_RESERVE,
    BIO__LEN_ORDERS,
    BIO__OFFSET_ARRAY_ORDERS
} batch_input_orders;

typedef enum {
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

typedef enum {
    S_NONE,
    S_BATCHED_INPUT_ORDERS,
    S_BATCHED_OUTPUT_ORDERS,
    S_ORDER,
} on_struct;

/* INestedFactory Functions */

typedef enum {
    DESTROY__TOKEN_ID,
    DESTROY__BUY_TOKEN,
    DESTROY__OFFSET_ORDERS,
    DESTROY__LEN_ORDERS,
    DESTROY__ORDERS,
} destroy_parameter;

// used for create, processInputOrder and processOutputOrder
typedef enum {
    CREATE__TOKEN_ID,
    CREATE__OFFSET_BIO,
    CREATE__LEN_BIO,
    CREATE__OFFSET_ARRAY_BIO,
} create_parameter;

/* FeeSplitter Functions */

typedef enum {
    RELEASE__OFFSET_TOKENS,
    RELEASE__LEN_TOKENS,
    RELEASE__ARRAY_TOKENS,
} release_tokens_parameter;

/* 721 Standard TransferFrom Function */

typedef enum {
    TRANSFER_FROM__FROM,
    TRANSFER_FROM__TO,
    TRANSFER_FROM__TOKEN_ID,
} transfer_from_parameter;

// Booleans
#define IS_COPY      (1)
#define TOKEN1_FOUND (1 << 2)
#define TOKEN2_FOUND (1 << 3)
// We can add 5 more booleans

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
// 124/160
typedef struct context_t {
    /* token1 */
    uint8_t token1_amount[INT256_LENGTH];
    uint8_t token1_address[ADDRESS_LENGTH];
    char token1_ticker[MAX_TICKER_LEN];
    uint8_t token1_decimals;

    /* token2 */
    uint8_t token2_address[ADDRESS_LENGTH];
    char token2_ticker[MAX_TICKER_LEN];

    /* ui_selector is the byte set by Nested frontend to determine the action put in screen ID */
    uint8_t ui_selector;

    /* Parsing */
    uint8_t on_struct;
    uint8_t next_param;

    /* number_of_tokens is the number of tokens found, this is not always the number of all tokens
     * include in the Tx */
    uint8_t number_of_tokens;

    /* current_tuple_offset is set when 'indentation' increase.
     * it is use to calculate targeted offset (to match msg->parameterOffset) on nested structures
     */
    uint32_t current_tuple_offset;

    /* last_batch_offset is the offset processInputOrder.batchedOrders[-1] */
    uint32_t last_batch_offset;

    /* last_order_offset is the offset of the last order struct in BOO/BIO structs
     * processInputOrder.batchedOrders[-1].orders[-1] */
    uint32_t last_order_offset;

    /* ui_selector_offset is the offset of the last byte (containing ui_selector), found after the
     * last order */
    uint32_t ui_selector_offset;

    /* current_length is the length of the current array/bytes we are parsing */
    uint16_t current_length;

    /* Method ID */
    selector_t selectorIndex;  // method id

    /* bitwise Booleans */
    uint8_t booleans;
} context_t;

// Piece of code that will check that the above structure is not bigger than 5
// * 32. Do not remove this check.
_Static_assert(sizeof(context_t) <= 5 * 32, "Structure of parameters too big.");

#define copy_number(parameter, T)              \
    _Generic((T), uint32_t *                   \
             : U4BE_from_parameter, uint16_t * \
             : U2BE_from_parameter, uint8_t *  \
             : copy_number_uint8, default      \
             : copy_type_error)(parameter, T)

#define add_numbers(T, to_add)           \
    _Generic((T), uint32_t *             \
             : add_in_uint32, uint16_t * \
             : add_in_uint16, uint8_t *  \
             : add_in_uint8, default     \
             : add_type_error)(T, to_add)

void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_init_contract(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);

void parse_order(ethPluginProvideParameter_t *msg, context_t *context);
void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context);
void parse_batched_output_orders(ethPluginProvideParameter_t *msg, context_t *context);

void msg_display_address_ui(ethQueryContractUI_t *msg, uint8_t *address);
void msg_ticker_or_address(ethQueryContractUI_t *msg, context_t *context, int flag);
void msg_2tickers_ui(ethQueryContractUI_t *msg, context_t *context);
void msg_number_of_tokens(ethQueryContractUI_t *msg, context_t *context, int flag);
void msg_amount_or_address_ui(ethQueryContractUI_t *msg, context_t *context);

bool copy_number_uint8(const uint8_t *parameter, uint8_t *target);
bool copy_type_error(const uint8_t *parameter, void *target);

bool add_in_uint32(uint32_t *target, uint32_t to_add);
bool add_in_uint16(uint16_t *target, uint32_t to_add);
bool add_in_uint8(uint8_t *target, uint32_t to_add);
bool add_type_error(void *target, uint32_t to_add);
