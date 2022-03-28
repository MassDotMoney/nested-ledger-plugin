#include "nested_plugin.h"
#define PLUGIN_NAME "Nested"

/* Screen strings */

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively used for the top and bottom text displays in the UI screens.

// Title string for 1st UI is always PLUGIN_NAME in src/handle_query_contract_id.c.
#define MSG_CREATE_ID "Create"
#define MSG_COPY_ID "Copy"
#define MSG_CLAIM_SINGLE_ID "Claim Royalties"
#define MSG_CLAIM_ALL_ID "Claim All"
#define MSG_PROCESS_INPUT_ORDERS_ID "PROCESS_INPUT_ORDERS"
#define MSG_PROCESS_OUTPUT_ORDERS_ID "PROCESS_OUTPUT_ORDERS"
#define MSG_DESTROY_ID "Sell Portfolio"
#define MSG_TRANSFER_FROM_ID "Send Portfolio"

#define TITLE_PLACEHOLDER "PLACEHOLDER"

///////////////////////

// Titles and messages are divided by actions.

/// CREATE ///

#define TITLE_CREATE_SENT_TOKEN "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

#define TITLE_CREATE_RECEIVED_TOKEN "Adding"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*

/// COPY ///

#define TITLE_COPY_SENT_TOKEN "Budget token:"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*

#define TITLE_COPY_RECEIVED_TOKEN "Copying"

/// DESTROY ///

#define TITLE_DESTROY_SENT_TOKEN "Selling:"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_*.

#define TITLE_DESTROY_RECEIVED_TOKEN "Receiving:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

/// CLAIM SINGLE///

#define TITLE_CLAIM_SINGLE_SENT_TOKEN "Claiming:"
// Msg string is displayed by MSG_NUMBER_OF_TOKENS_SINGLE.

#define MSG_RELEASE_TOKENS_SINGLE "XXX NAME"
#define MSG_RELEASE_TOKEN_MULTIPLE "X tokens"
#define TITLE_RELEASE_TOKENS_SINGLE "in"

/// CLAIM ALL///

#define TITLE_CLAIM_ALL_SENT_TOKEN "Claiming"
#define MSG_CLAIM_ALL_SENT_TOKEN "%s tokens TBD"

/// UTILS ///

//#define MSG_NUMBER_OF_TOKENS ({
//char *str;
//if (context->number_of_tokens > 1)
//    str = "tokens";
//else
//    str = "token";
//snprintf(msg->msg, msg->msgLength, "%d %s", context->number_of_tokens, &str);
//})

#define MSG_NUMBER_OF_TOKENS_SINGLE snprintf(msg->msg, msg->msgLength, "%d token", context->number_of_tokens + 1)
#define MSG_NUMBER_OF_TOKENS_PLURAL snprintf(msg->msg, msg->msgLength, "%d tokens", context->number_of_tokens)

#define UNKNOWN_TOKEN_TITLE "Unknown"
#define UNKNOWN_TOKEN_MSG "token:"