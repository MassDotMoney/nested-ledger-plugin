#pragma once

#include "debug.h"
#include "eth_internals.h"
#include "eth_plugin_interface.h"
#include <string.h>

// Number of decimals used when the token wasn't found in the Crypto Asset List.
#define DEFAULT_DECIMAL WEI_TO_ETHER
#define ETH_DECIMAL WEI_TO_ETHER

// Network tickers
#define MATIC "MATIC "
#define WMATIC "WMATIC "
#define AVAX "AVAX "
#define WAVAX "WAVAX "
#define BNB "BNB "
#define WBNB "WBNB "
#define ETH "ETH "
#define WETH "WETH "

// Utility addresses checking
#define NULL_ADDRESS "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
#define ADDRESS_IS_NETWORK_TOKEN(_addr)                                        \
  (!memcmp(_addr, NETWORK_TOKEN_ADDRESS, ADDRESS_LENGTH))
#define ADDRESS_IS_NULL_ADDRESS(_addr)                                         \
  (!memcmp(_addr, NULL_ADDRESS, ADDRESS_LENGTH))
extern const uint8_t NETWORK_TOKEN_ADDRESS[ADDRESS_LENGTH];

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

// selector of the Tx's last byte.
typedef enum {
  NONE,
  ADD_TOKENS,
  DEPOSIT,
  SYNCHRONIZATION,
  SELL_TOKENS,
  WITHDRAW,
  SWAP,
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
#define IS_COPY (1)
#define TOKEN1_FOUND (1 << 2)
#define TOKEN2_FOUND (1 << 3)
// We can add 5 more booleans

// Shared global memory with Ethereum app. Must be at most 5 * 32 bytes.
// 119 / 160
typedef struct __attribute__((__packed__)) context_t {
  uint8_t on_struct;
  uint8_t next_param;
  uint32_t next_offset;    // is the value of the next target offset
  uint16_t current_length; // is the length of the current array
  uint16_t target_offset;  // is the offset of the parameter we want to parse
  uint32_t current_tuple_offset; // is the value from which a given structure's
                                 // offset is calculated in nested structures,
                                 // it is set when 'indentation' increase.
  uint32_t last_calldata_offset; // is the offset of the last order's calldata
                                 // end, just before the last byte of the Tx
  uint8_t number_of_tokens; // is the number of tokens found, this is not always
                            // the number of all tokens include in the Tx
  /** token1 is often the input token */
  uint8_t token1_address[ADDRESS_LENGTH];
  uint8_t token1_amount[INT256_LENGTH];
  uint8_t token1_decimals;
  char token1_ticker[MAX_TICKER_LEN];
  /** token2 is the output token */
  uint8_t token2_address[ADDRESS_LENGTH];
  char token2_ticker[MAX_TICKER_LEN];
  uint8_t ui_selector;      // ui_selector is the byte set by Nested front to
                            // determine the action
  selector_t selectorIndex; // method id
  uint8_t booleans;         // bitwise booleans
} context_t;

// Piece of code that will check that the above structure is not bigger than 5
// * 32. Do not remove this check.
_Static_assert(sizeof(context_t) <= 5 * 32, "Structure of parameters too big.");

void handle_provide_parameter(void *parameters);
void handle_query_contract_ui(void *parameters);
void handle_init_contract(void *parameters);
void handle_finalize(void *parameters);
void handle_provide_token(void *parameters);
void handle_query_contract_id(void *parameters);

void parse_order(ethPluginProvideParameter_t *msg, context_t *context);
void parse_batched_input_orders(ethPluginProvideParameter_t *msg,
                                context_t *context);
void parse_batched_output_orders(ethPluginProvideParameter_t *msg,
                                 context_t *context);

void msg_display_address_ui(ethQueryContractUI_t *msg, uint8_t *address);
void msg_ticker_or_address(ethQueryContractUI_t *msg, context_t *context,
                           int flag);
void msg_2tickers_ui(ethQueryContractUI_t *msg, context_t *context);
void msg_number_of_tokens(ethQueryContractUI_t *msg, context_t *context,
                          int flag);
void msg_amount_or_address_ui(ethQueryContractUI_t *msg, context_t *context);
