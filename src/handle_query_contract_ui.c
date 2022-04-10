#include "nested_plugin.h"
#include "text.h"

static void handle_create_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        // Edit these to change screens.
        strlcpy(msg->title, TITLE_CREATE_SCREEN_1_UI, msg->titleLength);
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_CREATE_SCREEN_2_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS_UI;
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_COPY_SCREEN_2_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS_UI;
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_sell_portfolio_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (msg->screenIndex)
    {
    case 0:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_1_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_2_UI, msg->titleLength);
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_SWAP_SCREEN_2_UI, msg->titleLength);
        MSG_TOKEN2_TICKER_OR_ADDRESS_UI;
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_ADD_TOKENS_SCREEN_2_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS_UI;
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
        MSG_NUMBER_OF_TOKENS_UI;
        break;
    case 1:
        strlcpy(msg->title, TITLE_SELL_TOKENS_SCREEN_2_UI, msg->titleLength);
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void handle_synchronization_ui(ethQueryContractUI_t *msg, context_t *context)
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
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
        MSG_TOKEN1_AMOUNT_OR_ADDRESS_UI;
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
        MSG_NUMBER_OF_TOKENS_UI;
        break;
    case 1: // Only if 2 tokens found by app.
        strlcpy(msg->title, TITLE_CLAIM_SCREEN_2_UI, msg->titleLength);
        MSG_2_TICKERS_UI;
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
        msg->msg[0] = '0';
        msg->msg[1] = 'x';
        //getEthAddressStringFromBinary((uint8_t *)context->token1_address,
        //                              (uint8_t *)msg->msg + 2,
        //                              msg->pluginSharedRW->sha3,
        //                              0);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
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

    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            handle_copy_ui(msg, context);
        else
            handle_create_ui(msg, context);
    case PROCESS_INPUT_ORDERS:
        // handle_add_tokens_ui(msg, context);
        break;
    case PROCESS_OUTPUT_ORDERS:
        break;
    case DESTROY:
        handle_sell_portfolio_ui(msg, context);
        break;
    case RELEASE_TOKENS:
        if (context->number_of_tokens == 1)
            handle_claim_single_ui(msg, context);
        else
            handle_claim_all_ui(msg, context);
        break;
    case TRANSFER_FROM:
        break;
    default:
        PRINTF("AN ERROR OCCURED IN UI\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
