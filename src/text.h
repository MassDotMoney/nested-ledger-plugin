#include "nested_plugin.h"
#define PLUGIN_NAME "Nested"

// Use this header file to simply modify the strings displayed.
// TITLE and MSG strings are respectively listed by order of appearance and used
// for the top and bottom text displays in the UI screen.

/* handle_query_contract_id.c strings */

// TITLE string for 1st UI is PLUGIN_NAME.
#define MSG_CREATE_ID          "Create Portfolio"
#define MSG_COPY_ID            "Replicate a Portfolio"
#define MSG_CLAIM_ID           "Claim Royalties"
#define MSG_DESTROY_ID         "Sell Portfolio"
#define MSG_TRANSFER_FROM_ID   "Send Portfolio"
#define MSG_ADD_TOKEN_ID       "Add tokens"
#define MSG_DEPOSIT_ID         "Deposit"
#define MSG_SYNCHRONIZATION_ID "Synchronization"
#define MSG_SWAP_ID            "Swap"
#define MSG_WITHDRAW_ID        "Withdraw"
#define MSG_SELL_TOKENS_ID     "Sell Tokens"

/* handle_query_contract_ui.c strings */

/// CREATE ///

#define TITLE_CREATE_SCREEN_1_UI "Budget token:"
#define TITLE_CREATE_SCREEN_2_UI "Adding to portfolio:"

/// COPY ///

#define TITLE_COPY_SCREEN_1_UI "Budget token:"
#define TITLE_COPY_SCREEN_2_UI "Replicating"

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
#define MSG_SYNCHRONIZATION_SCREEN_1_UI   "porfolio."

/// DEPOSIT ///

#define TITLE_DEPOSIT_SCREEN_1_UI "Depositing"

/// WITHDRAW ///

#define TITLE_WITHDRAW_SCREEN_1_UI "Withdrawing"

/// CLAIM ///

#define TITLE_CLAIM_SCREEN_1_UI "Claiming"
#define TITLE_CLAIM_SCREEN_2_UI "Claimed Tokens:"

/// SEND ///

#define TITLE_SEND_SCREEN_1_UI "Sending to:"
