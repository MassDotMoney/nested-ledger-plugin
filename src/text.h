#include "nested_plugin.h"
#define PLUGIN_NAME "Nested"

/* Screen strings */

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively used for the top and bottom text displays in the UI screen.

// Title string for 1st UI is always PLUGIN_NAME in src/handle_query_contract_id.c.
#define MSG_CREATE_ID "Create Portfolio"
#define MSG_COPY_ID "Copy Portfolio"
#define MSG_CLAIM_ID "Claim Royalties"
#define MSG_DESTROY_ID "Sell Portfolio"
#define MSG_TRANSFER_FROM_ID "Send Portfolio"
#define MSG_ADD_TOKEN_ID "Add tokens"
#define MSG_DEPOSIT_ID "Deposit"
#define MSG_SYNCHRONIZATION_ID "Synchronization"
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

#define TITLE_SYNCHRONIZATION_SCREEN_1_UI "Updating"
#define MSG_SYNCHRONIZATION_SCREEN_1_UI "porfolio."

/// DEPOSIT ///

#define TITLE_DEPOSIT_SCREEN_1_UI "Depositing"

/// WITHDRAW ///

#define TITLE_WITHDRAW_SCREEN_1_UI "Withdrawing"

/// CLAIM ///

#define TITLE_CLAIM_SCREEN_1_UI "Claiming"
#define TITLE_CLAIM_SCREEN_2_UI "Claimed Tokens:"

/// SEND ///

#define TITLE_SEND_SCREEN_1_UI "Sending to:"

/// UTILS ///

#define MSG_NUMBER_OF_TOKENS_UI (                                                           \
    {                                                                                       \
        if (context->booleans & TOKEN2_FOUND && context->number_of_tokens == 1)             \
        {                                                                                   \
            PRINTF("GPIRIOU DEBUG\n");                                                      \
            snprintf(msg->msg, msg->msgLength, "%s", context->token2_ticker);               \
        }                                                                                   \
        else                                                                                \
        {                                                                                   \
            if (context->number_of_tokens > 1)                                              \
                snprintf(msg->msg, msg->msgLength, "%d tokens", context->number_of_tokens); \
            else                                                                            \
                snprintf(msg->msg, msg->msgLength, "%d token", context->number_of_tokens);  \
        }                                                                                   \
    })

#define MSG_DISPLAY_TOKEN1_ADDRESS (                                      \
    {                                                                     \
        msg->msg[0] = '0';                                                \
        msg->msg[1] = 'x';                                                \
        getEthAddressStringFromBinary((uint8_t *)context->token1_address, \
                                      (char *)msg->msg + 2,               \
                                      msg->pluginSharedRW->sha3,          \
                                      0);                                 \
    })

#define MSG_DISPLAY_TOKEN2_ADDRESS (                                      \
    {                                                                     \
        msg->msg[0] = '0';                                                \
        msg->msg[1] = 'x';                                                \
        getEthAddressStringFromBinary((uint8_t *)context->token2_address, \
                                      (char *)msg->msg + 2,               \
                                      msg->pluginSharedRW->sha3,          \
                                      0);                                 \
    })

#define MSG_2_TICKERS_UI snprintf(msg->msg, msg->msgLength, "%s and %s", context->token1_ticker, context->token2_ticker)

#define MSG_TOKEN1_TICKER_OR_ADDRESS_UI (                                     \
    {                                                                         \
        if (context->booleans & TOKEN1_FOUND)                                 \
            snprintf(msg->msg, msg->msgLength, "%s", context->token1_ticker); \
        else                                                                  \
            MSG_DISPLAY_TOKEN1_ADDRESS;                                       \
    })

#define MSG_TOKEN2_TICKER_OR_ADDRESS_UI (                                     \
    {                                                                         \
        if (context->booleans & TOKEN2_FOUND)                                 \
            snprintf(msg->msg, msg->msgLength, "%s", context->token2_ticker); \
        else                                                                  \
            MSG_DISPLAY_TOKEN2_ADDRESS;                                       \
    })

#define MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI (                                                              \
    {                                                                                                  \
        if (context->booleans & TOKEN1_FOUND)                                                          \
        {                                                                                              \
            PRINTF("GPIRIOU amount: %.*H\n", sizeof(context->token1_address), context->token1_amount); \
            amountToString(context->token1_amount, sizeof(context->token1_amount),                     \
                           context->token1_decimals,                                                   \
                           context->token1_ticker,                                                     \
                           msg->msg,                                                                   \
                           msg->msgLength);                                                            \
            PRINTF("penzo_msg: %.*H\n", msg->msgLength, msg->msg);                                     \
        }                                                                                              \
        else                                                                                           \
            MSG_DISPLAY_TOKEN1_ADDRESS;                                                                \
    })
