#include "nested_plugin.h"
#include "text.h"

static void handle_create_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        // Edit these to change screens.
        strlcpy(msg->title, TITLE_CREATE_SCREEN_1_UI, msg->titleLength);
        msg_amount_or_address_ui(msg, context);
        break;
    case 1:
        strlcpy(msg->title, TITLE_CREATE_SCREEN_2_UI, msg->titleLength);
        msg_number_of_tokens(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_copy_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_COPY_SCREEN_1_UI, msg->titleLength);
        msg_amount_or_address_ui(msg, context);
        break;
    case 1:
        strlcpy(msg->title, TITLE_COPY_SCREEN_2_UI, msg->titleLength);
        msg_number_of_tokens(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_destroy_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_1_UI, msg->titleLength);
        msg_number_of_tokens(msg, context, 2);
        break;
    case 1:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_2_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 1);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_swap_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SWAP_SCREEN_1_UI, msg->titleLength);
        msg_amount_or_address_ui(msg, context);
        break;
    case 1:
        strlcpy(msg->title, TITLE_SWAP_SCREEN_2_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_add_tokens_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_ADD_TOKENS_SCREEN_1_UI, msg->titleLength);
        msg_amount_or_address_ui(msg, context);
        break;
    case 1:
        strlcpy(msg->title, TITLE_ADD_TOKENS_SCREEN_2_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_sell_tokens_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SELL_TOKENS_SCREEN_1_UI, msg->titleLength);
        msg_number_of_tokens(msg, context, 1);
        break;
    case 1:
        strlcpy(msg->title, TITLE_SELL_TOKENS_SCREEN_2_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_synchronization_ui(ethQueryContractUI_t *msg)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SYNCHRONIZATION_SCREEN_1_UI, msg->titleLength);
        strlcpy(msg->msg, MSG_SYNCHRONIZATION_SCREEN_1_UI, msg->msgLength);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_deposit_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_DEPOSIT_SCREEN_1_UI, msg->titleLength);
        msg_amount_or_address_ui(msg, context);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_withdraw_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_WITHDRAW_SCREEN_1_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_claim_single_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_CLAIM_SCREEN_1_UI, msg->titleLength);
        msg_ticker_or_address(msg, context, 1);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_claim_all_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_CLAIM_SCREEN_1_UI, msg->titleLength);
        msg_number_of_tokens(msg, context, 1);
        break;
    case 1: // Only if 2 tokens found by ledgerjs.
        strlcpy(msg->title, TITLE_CLAIM_SCREEN_2_UI, msg->titleLength);
        msg_2tickers_ui(msg, context);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_send_portfolio_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SEND_SCREEN_1_UI, msg->titleLength);
        msg_display_address_ui(msg, context->token1_address);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void convert_ticker(char token1_ticker[MAX_TICKER_LEN], char network_ticker[MAX_TICKER_LEN])
{
    if (!(memcmp(ETH, network_ticker, sizeof(ETH)))) // Check chain ID
    {
        if (!(memcmp(token1_ticker, WETH, sizeof(WETH))))
            strlcpy(token1_ticker, ETH, MAX_TICKER_LEN);
    }
    else if (!(memcmp(MATIC, network_ticker, sizeof(MATIC)))) // Check chain ID
    {
        if (!(memcmp(token1_ticker, WMATIC, sizeof(WMATIC))))
            strlcpy(token1_ticker, MATIC, MAX_TICKER_LEN);
    }
    else if (!(memcmp(AVAX, network_ticker, sizeof(AVAX)))) // Check chain ID
    {
        if (!(memcmp(token1_ticker, WAVAX, sizeof(WAVAX))))
            strlcpy(token1_ticker, AVAX, MAX_TICKER_LEN);
    }
    else if (!(memcmp(BNB, network_ticker, sizeof(BNB)))) // Check chain ID
    {
        if (!(memcmp(token1_ticker, WBNB, sizeof(WBNB))))
            strlcpy(token1_ticker, BNB, MAX_TICKER_LEN);
    }
}

void handle_query_contract_ui(void *parameters)
{
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
    memset(msg->msg, 0, msg->msgLength);

    msg->result = ETH_PLUGIN_RESULT_OK;

    // Get network ticker if address is '0xeee...'
    if (ADDRESS_IS_NETWORK_TOKEN(context->token1_address))
        strlcpy(context->token1_ticker, msg->network_ticker, sizeof(context->token1_ticker));
    if (ADDRESS_IS_NETWORK_TOKEN(context->token2_address))
        strlcpy(context->token2_ticker, msg->network_ticker, sizeof(context->token2_ticker));

    // Remove 'W' from network token. (WETH => ETH)
    convert_ticker(context->token1_ticker, msg->network_ticker);
    convert_ticker(context->token2_ticker, msg->network_ticker);

    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            handle_copy_ui(msg, context);
        else
            handle_create_ui(msg, context);
        break;
    case PROCESS_INPUT_ORDERS:
        if (context->ui_selector == ADD_TOKENS)
            handle_add_tokens_ui(msg, context);
        else if (context->ui_selector == DEPOSIT)
            handle_deposit_ui(msg, context);
        else if (context->ui_selector == SYNCHRONIZATION)
            handle_synchronization_ui(msg);
        else
        {
            PRINTF("Error in handle_query_contract_ui's ui_selector switch\n");
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
        }
        break;
    case PROCESS_OUTPUT_ORDERS:
        if (context->ui_selector == SELL_TOKENS)
            handle_sell_tokens_ui(msg, context);
        else if (context->ui_selector == WITHDRAW)
            handle_withdraw_ui(msg, context);
        else if (context->ui_selector == SWAP)
            handle_swap_ui(msg, context);
        else
        {
            PRINTF("Error in handle_query_contract_ui's ui_selector switch\n");
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
        }
        break;
    case DESTROY:
        handle_destroy_ui(msg, context);
        break;
    case RELEASE_TOKENS:
        if (context->number_of_tokens == 1)
            handle_claim_single_ui(msg, context);
        else
            handle_claim_all_ui(msg, context);
        break;
    case TRANSFER_FROM:
        handle_send_portfolio_ui(msg, context);
        break;
    default:
        PRINTF("Error in handle_query_contract_ui's selectorIndex switch\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
