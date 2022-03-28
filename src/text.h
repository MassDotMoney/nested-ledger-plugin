#include "nested_plugin.h"
#define PLUGIN_NAME "Nested"

/* Screen strings */

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively used for the top and bottom text displays in the UI screens.

// Title string for 1st UI is always PLUGIN_NAME in src/handle_query_contract_id.c.
#define MSG_CREATE_ID "Create"
#define MSG_COPY_ID "Copy"
#define MSG_CLAIM_ID "Claim Royalties"
#define MSG_PROCESS_INPUT_ORDERS_ID "PROCESS_INPUT_ORDERS"
#define MSG_PROCESS_OUTPUT_ORDERS_ID "PROCESS_OUTPUT_ORDERS"
#define MSG_DESTROY_ID "Sell Portfolio"
#define MSG_TRANSFER_FROM_ID "Send Portfolio"

#define TITLE_PLACEHOLDER "PLACEHOLDER"

///////////////////////

// Titles and messages are divided by actions.

/// CREATE ///

#define TITLE_CREATE_SCREEN_1_UI "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c
#define TITLE_CREATE_SCREEN_2_UI "Adding"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*

/// COPY ///

#define TITLE_COPY_SCREEN_1_UI "Budget token:"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*
#define TITLE_COPY_SCREEN_2_UI "Copying"

/// SELL PORTFOLIO ///

#define TITLE_SELL_PORTFOLIO_SCREEN_1_UI "Selling"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*.
#define TITLE_SELL_PORTFOLIO_SCREEN_2_UI "Receiving"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

/// CLAIM ///

#define TITLE_CLAIM_SCREEN_1_UI "Claiming"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*.
#define TITLE_CLAIM_SCREEN_2_UI_SINGLE "Claimed Token:"
#define TITLE_CLAIM_SCREEN_2_UI_PLURAL "Claimed Tokens:"
#define MSG_CLAIM_2_TOKENS_SCREEN_2_UI snprintf(msg->msg, msg->msgLength, "%s and %s.", context->token1_ticker, context->token2_ticker)

/// UTILS ///

//#define MSG_NUMBER_OF_TOKENS ({
//char *str;
//if (context->number_of_tokens > 1)
//    snprintf(msg->msg, msg->msgLength, "%d %s", context->number_of_tokens, "tokens");
//else
//    snprintf(msg->msg, msg->msgLength, "%d %s", context->number_of_tokens, "token");
//})

#define MSG_NUMBER_OF_TOKENS_SINGLE snprintf(msg->msg, msg->msgLength, "%d token.", context->number_of_tokens + 1)
#define MSG_NUMBER_OF_TOKENS_PLURAL snprintf(msg->msg, msg->msgLength, "%d tokens", context->number_of_tokens)

#define UNKNOWN_TOKEN_TITLE "Unknown"
#define UNKNOWN_TOKEN_MSG "token:"