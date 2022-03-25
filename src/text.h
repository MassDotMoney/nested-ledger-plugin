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

// Titles and messages are divided by actions.

/// CREATE ///

#define TITLE_CREATE_DEPOSITED_TOKEN "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

#define TITLE_CREATE_RECEIVED_TOKEN "Adding:"
#define MSG_CREATE_RECEIVED_TOKEN "%s tokens TBD"

/// COPY ///

#define TITLE_COPY_DEPOSITED_TOKEN "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

#define TITLE_COPY_RECEIVED_TOKEN "Copying:"
#define MSG_COPY_RECEIVED_TOKEN "%s tokens TBD"

/// DESTROY ///

#define TITLE_DESTROY_

#define UNKNOWN_PAYMENT_TOKEN_TITLE "Unknown"
#define UNKNOWN_PAYMENT_TOKEN_MSG "payment token"