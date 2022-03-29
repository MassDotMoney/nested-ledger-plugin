#include "nested_plugin.h"
#include "text.h"

//static void print_screen_array(context_t *context)
//{
//    PRINTF("FIRST_SCREEN_UI %d\n", context->screen_array & FIRST_SCREEN_UI);
//    PRINTF("SCREEN_2_UI %d\n", context->screen_array & SCREEN_2_UI);
//    PRINTF("SCREEN_3_UI %d\n", context->screen_array & SCREEN_3_UI);
//    // PRINTF("SCREEN_UI_4 %d\n", context->screen_array & SCREEN_UI_4);
//    // PRINTF("SCREEN_UI_5 %d\n", context->screen_array & SCREEN_UI_5);
//    // PRINTF("SCREEN_UI_6 %d\n", context->screen_array & SCREEN_UI_6);
//    // PRINTF("SCREEN_UI_7 %d\n", context->screen_array & SCREEN_UI_7);
//    // PRINTF("LAST_UI %d\n", context->screen_array & LAST_UI);
//}

//static void set_warning_ui(ethQueryContractUI_t *msg, context_t *context)
//{
//    PRINTF("GPIRIOU WARNING DEBUG\n");
//    strlcpy(msg->title, UNKNOWN_TOKEN_TITLE, msg->titleLength);
//    strlcpy(msg->msg, UNKNOWN_TOKEN_MSG, msg->msgLength);
//}

static void set_screen_1_ui(ethQueryContractUI_t *msg, context_t *context)
{
    PRINTF("GPIRIOU in set_screen_1_ui, on %d selector\n", context->selectorIndex);
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->title, TITLE_COPY_SCREEN_1_UI, msg->titleLength);
        else
            strlcpy(msg->title, TITLE_CREATE_SCREEN_1_UI, msg->titleLength);
        if (context->booleans & TOKEN1_FOUND)
        {
            amountToString(context->token1_amount, sizeof(context->token1_amount),
                           context->token1_decimals,
                           context->token1_ticker,
                           msg->msg,
                           msg->msgLength);
        }
        else
        {
            msg->msg[0] = '0';
            msg->msg[1] = 'x';
            getEthAddressStringFromBinary((uint8_t *)context->token1_address,
                                          (uint8_t *)msg->msg + 2,
                                          msg->pluginSharedRW->sha3,
                                          0);
        }
        break;
    // case PROCESS_INPUT_ORDERS:

    //     break;
    case DESTROY:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_1_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS;
        break;
    case RELEASE_TOKENS: ///////// WIP
        strlcpy(msg->title, TITLE_CLAIM_SCREEN_1_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS;
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void set_screen_2_ui(ethQueryContractUI_t *msg, context_t *context)
{
    PRINTF("GPIRIOU in set_screen_2_ui, on %d selector\n", context->selectorIndex);
    PRINTF("GPIRIOU %d\n", context->number_of_tokens);
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->title, TITLE_COPY_SCREEN_2_UI, msg->titleLength);
        else
            strlcpy(msg->title, TITLE_CREATE_SCREEN_2_UI, msg->titleLength);
        MSG_NUMBER_OF_TOKENS;
        break;
    case DESTROY:
        strlcpy(msg->title, TITLE_SELL_PORTFOLIO_SCREEN_2_UI, msg->titleLength);
        amountToString(context->token1_amount, sizeof(context->token1_amount),
                       context->token1_decimals,
                       context->token1_ticker,
                       msg->msg,
                       msg->msgLength);
        break;
    case RELEASE_TOKENS:
        PRINTF("GPIRIOU RELEASE NUMBER OF TOKENS: %d\n", context->number_of_tokens);
        TITLE_CLAIM_SCREEN_2_UI;
        if (context->booleans & TOKEN1_FOUND && context->booleans & TOKEN2_FOUND)
        {
            print_bytes(context->token1_address, sizeof(context->token1_address));
            PRINTF("GPIRIOU ADDRESS1: %s\n", context->token2_ticker);
            MSG_CLAIM_2_TOKENS_SCREEN_2_UI;
        }
        else
            MSG_NUMBER_OF_TOKENS;
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

    switch (msg->screenIndex)
    {
    case 0:
        set_screen_1_ui(msg, context);
        break;
    case 1:
        set_screen_2_ui(msg, context);
        break;
    case 2:
        // set_screen_3_ui(msg, context);
        break;
    default:
        PRINTF("AN ERROR OCCURED IN UI\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
