#include "nested_plugin.h"
#define PLUGIN_NAME "Nested"

/* Screen strings */

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively used for the top and bottom text displays in the UI screens.

// Title string for 1st UI is always PLUGIN_NAME in src/handle_query_contract_id.c.
#define MSG_CREATE_ID "Create Portfolio"
#define MSG_COPY_ID "Copy Portfolio"
#define MSG_CLAIM_ID "Claim Royalties"
#define MSG_SYNCHRONIZATION_ID "Syncrhonization"
#define MSG_DESTROY_ID "Sell Portfolio"
#define MSG_TRANSFER_FROM_ID "Send Portfolio"

// #define MSG_PROCESS_INPUT_ORDERS_ID "PROCESS_INPUT_ORDERS"
#define MSG_ADD_TOKEN_ID "Add tokens"
#define MSG_DEPOSIT_ID "Deposit"
#define MSG_SYNCHRONIZATION_ID "Syncrhonization"

#define MSG_PROCESS_OUTPUT_ORDERS_ID "PROCESS_OUTPUT_ORDERS"
#define MSG_SWAP_ID "Swap"
#define MSG_WITHDRAW_ID "Withdraw"
#define MSG_SELL_TOKENS_ID "Sell Tokens"

///////////////////////

// Titles and messages are listed by order of appearance.

/// CREATE ///

#define TITLE_CREATE_SCREEN_1_UI "Budget token:"
#define TITLE_CREATE_SCREEN_2_UI "Adding to portfolio:"

/// COPY ///

#define TITLE_COPY_SCREEN_1_UI "Budget token:"
#define TITLE_COPY_SCREEN_2_UI "Copying"

/// SELL PORTFOLIO ///

#define TITLE_SELL_PORTFOLIO_SCREEN_1_UI "Selling"
#define TITLE_SELL_PORTFOLIO_SCREEN_2_UI "Receiving"

/// SWAP ///

#define TITLE_SWAP_SCREEN_1_UI "Swapping:"
#define TITLE_SWAP_SCREEN_2_UI "Receiving:"

/// ADD TOKENS ///

#define TITLE_ADD_TOKENS_SCREEN_1_UI "Budget Token:"
#define TITLE_ADD_TOKENS_SCREEN_2_UI "Adding"

/// SELL TOKENS ///

#define TITLE_SELL_TOKENS_SCREEN_1_UI "Selling"
#define TITLE_SELL_TOKENS_SCREEN_2_UI "Receiving"

/// SYNCHRONIZATION ///

#define TITLE_SYNCHRONIZATION_SCREEN_1_UI "Synchronizing"
#define MSG_SYNCHRONIZATION_SCREEN_1_UI "with portfolio."

/// DEPOSIT ///

#define TITLE_DEPOSIT_SCREEN_1_UI "Depositing"
#define MSG_DEPOSIT_SCREEN_1_UI ""

/// WITHDRAW ///

#define TITLE_WITHDRAW_SCREEN_1_UI "Withdrawing"
#define MSG_WITHDRAW_SCREEN_1_UI ""

/// CLAIM ///

#define TITLE_CLAIM_SCREEN_1_UI "Claiming"
#define TITLE_CLAIM_SCREEN_2_UI "Claimed Tokens:"

/// SEND ///

#define TITLE_SEND_SCREEN_1_UI "Sending to:"

/// UTILS ///

#define MSG_TICKER1_UI snprintf(msg->msg, msg->msgLength, "%s", context->token1_ticker)
#define MSG_TICKER2_UI snprintf(msg->msg, msg->msgLength, "%s", context->token2_ticker)
#define MSG_2_TICKERS_UI snprintf(msg->msg, msg->msgLength, "%s and %s", context->token1_ticker, context->token2_ticker)

#define MSG_NUMBER_OF_TOKENS_UI (                                                              \
    {                                                                                          \
        if (context->number_of_tokens > 1)                                                     \
            snprintf(msg->msg, msg->msgLength, "%d %s", context->number_of_tokens, "tokens."); \
        else                                                                                   \
            snprintf(msg->msg, msg->msgLength, "%d %s", context->number_of_tokens, "token.");  \
    })

#define MSG_DISPLAY_TOKEN1_ADDRESS (                                      \
    {                                                                     \
        msg->msg[0] = '0';                                                \
        msg->msg[1] = 'x';                                                \
        getEthAddressStringFromBinary((uint8_t *)context->token1_address, \
                                      (uint8_t *)msg->msg + 2,            \
                                      msg->pluginSharedRW->sha3,          \
                                      0);                                 \
    })

#define MSG_DISPLAY_TOKEN2_ADDRESS (                                      \
    {                                                                     \
        msg->msg[0] = '0';                                                \
        msg->msg[1] = 'x';                                                \
        getEthAddressStringFromBinary((uint8_t *)context->token2_address, \
                                      (uint8_t *)msg->msg + 2,            \
                                      msg->pluginSharedRW->sha3,          \
                                      0);                                 \
    })

#define MSG_TOKEN1_TICKER_OR_ADDRESS_UI (     \
    {                                         \
        if (context->booleans & TOKEN1_FOUND) \
            MSG_TICKER1_UI;                   \
        else                                  \
            MSG_DISPLAY_TOKEN1_ADDRESS;       \
    })

#define MSG_TOKEN2_TICKER_OR_ADDRESS_UI (     \
    {                                         \
        if (context->booleans & TOKEN2_FOUND) \
            MSG_TICKER2_UI;                   \
        else                                  \
            MSG_DISPLAY_TOKEN2_ADDRESS;       \
    })

#define MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI (                                          \
    {                                                                              \
        if (context->booleans & TOKEN1_FOUND)                                      \
        {                                                                          \
            amountToString(context->token1_amount, sizeof(context->token1_amount), \
                           context->token1_decimals,                               \
                           context->token1_ticker,                                 \
                           msg->msg,                                               \
                           msg->msgLength);                                        \
        }                                                                          \
        else                                                                       \
            MSG_DISPLAY_TOKEN1_ADDRESS;                                            \
    })

//#define UNKNOWN_TOKEN_TITLE "Unknown"
//#define UNKNOWN_TOKEN_MSG "token:"