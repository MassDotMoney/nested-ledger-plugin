#define PLUGIN_NAME "Nested"

/* Screen strings */

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively used for the top and bottom text displays in the UI screens.

// Title string for 1st UI is always PLUGIN_NAME in src/handle_query_contract_id.c.
#define CREATE_ID_MSG "Create"
#define COPY_ID_MSG "Copy"
#define CLAIM_SINGLE_ID_MSG "Claim Royalties"
#define CLAIM_ALL_ID_MSG "Claim All"
#define PROCESS_INPUT_ORDERS_ID_MSG "PROCESS_INPUT_ORDERS"
#define PROCESS_OUTPUT_ORDERS_ID_MSG "PROCESS_OUTPUT_ORDERS"
#define DESTROY_ID_MSG "Sell All"
#define TRANSFER_FROM_ID_MSG "Send Portfolio"

#define TITLE_PLACEHOLDER "PLACEHOLDER"

// Titles and messages are divided by actions.

/// CREATE ///

#define CREATE_DEPOSITED_TOKEN_TITLE "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

#define CREATE_RECEIVED_TOKEN_TITLE "Adding:"
#define CREATE_RECEIVED_TOKEN_MSG "%s tokens TBD"

/// COPY ///

#define COPY_DEPOSITED_TOKEN_TITLE "Budget token:"
// Msg string is displayed by AmountToString in src/handle_query_contract_ui.c

#define COPY_RECEIVED_TOKEN_TITLE "Copying:"
#define COPY_RECEIVED_TOKEN_MSG "%s tokens TBD"

// Warning strings
#define UNKNOWN_PAYMENT_TOKEN_TITLE "Unknown"
#define UNKNOWN_PAYMENT_TOKEN_MSG "payment token"