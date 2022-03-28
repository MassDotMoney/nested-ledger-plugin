#include "nested_plugin.h"
#include "text.h"

static void print_screen_array(context_t *context)
{
    PRINTF("FIRST_SCREEN_UI %d\n", context->screen_array & FIRST_SCREEN_UI);
    PRINTF("SCREEN_2_UI %d\n", context->screen_array & SCREEN_2_UI);
    PRINTF("SCREEN_3_UI %d\n", context->screen_array & SCREEN_3_UI);
    // PRINTF("SCREEN_UI_4 %d\n", context->screen_array & SCREEN_UI_4);
    // PRINTF("SCREEN_UI_5 %d\n", context->screen_array & SCREEN_UI_5);
    // PRINTF("SCREEN_UI_6 %d\n", context->screen_array & SCREEN_UI_6);
    // PRINTF("SCREEN_UI_7 %d\n", context->screen_array & SCREEN_UI_7);
    // PRINTF("LAST_UI %d\n", context->screen_array & LAST_UI);
}

//static void set_warning_ui(ethQueryContractUI_t *msg, context_t *context)
//{
//    PRINTF("GPIRIOU WARNING DEBUG\n");
//    strlcpy(msg->title, UNKNOWN_TOKEN_TITLE, msg->titleLength);
//    strlcpy(msg->msg, UNKNOWN_TOKEN_MSG, msg->msgLength);
//}

static void set_sent_tokens_ui(ethQueryContractUI_t *msg, context_t *context)
{
    PRINTF("GPIRIOU in set_sent_tokens_ui, on %d selector\n", context->selectorIndex);
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->title, TITLE_COPY_SENT_TOKEN, msg->titleLength);
        else
            strlcpy(msg->title, TITLE_CREATE_SENT_TOKEN, msg->titleLength);
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
    case DESTROY:
        strlcpy(msg->title, TITLE_DESTROY_SENT_TOKEN, msg->titleLength);
        if (context->number_of_tokens <= 1)
            MSG_NUMBER_OF_TOKENS_SINGLE;
        else
            MSG_NUMBER_OF_TOKENS_PLURAL;
        break;
    case RELEASE_TOKENS:
        strlcpy(msg->title, "in", msg->titleLength);
        strlcpy(msg->msg, context->token1_ticker, msg->msgLength);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void set_received_tokens_ui(ethQueryContractUI_t *msg, context_t *context)
{
    PRINTF("GPIRIOU in set_received_tokens_ui, on %d selector\n", context->selectorIndex);
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->title, TITLE_COPY_RECEIVED_TOKEN, msg->titleLength);
        else
            strlcpy(msg->title, TITLE_CREATE_RECEIVED_TOKEN, msg->titleLength);
        if (context->number_of_tokens <= 1)
            MSG_NUMBER_OF_TOKENS_SINGLE;
        else
            MSG_NUMBER_OF_TOKENS_PLURAL;
        break;
    case DESTROY:
        PRINTF("GPIRIOU token2: %d\n", TOKEN2_FOUND);
        strlcpy(msg->title, TITLE_DESTROY_RECEIVED_TOKEN, msg->titleLength);
        amountToString(context->token1_amount, sizeof(context->token1_amount),
                       context->token1_decimals,
                       context->token1_ticker,
                       msg->msg,
                       msg->msgLength);
        break;
    case RELEASE_TOKENS:
        strlcpy(msg->title, "and", msg->titleLength);
        strlcpy(msg->msg, context->token2_ticker, msg->msgLength);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void set_screen3(ethQueryContractUI_t *msg, context_t *context)
{
    switch (context->selectorIndex)
    {
    case RELEASE_TOKENS:
        strlcpy(msg->title, "and", msg->titleLength);
        snprintf(msg->msg, msg->msgLength, "%d more tokens", context->number_of_tokens - 2);
        break;
    default:
        strlcpy(msg->title, "ERROR", msg->titleLength);
        strlcpy(msg->msg, "ERROR", msg->msgLength);
        break;
    }
}

static void skip_right(context_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index << 1))
        context->plugin_screen_index <<= 1;
    context->plugin_screen_index <<= 1;
}

static void skip_left(context_t *context)
{
    while (!(context->screen_array & context->plugin_screen_index >> 1))
        context->plugin_screen_index >>= 1;
    context->plugin_screen_index >>= 1;
}

static bool get_scroll_direction(uint8_t screen_index, uint8_t previous_screen_index)
{
    if (screen_index > previous_screen_index || screen_index == 0)
        return RIGHT_SCROLL;
    else
        return LEFT_SCROLL;
}

static void get_screen_array(ethQueryContractUI_t *msg, context_t *context)
{
    if (msg->screenIndex == 0)
    {
        context->plugin_screen_index = FIRST_SCREEN_UI;
        context->previous_screen_index = 0;
        return;
    }
    // This should only happen on last valid Screen
    if (msg->screenIndex == context->previous_screen_index)
    {
        context->plugin_screen_index = LAST_UI;
        // if LAST_UI is up, stop on it.
        if (context->screen_array & LAST_UI)
            return;
    }
    bool scroll_direction = get_scroll_direction(msg->screenIndex, context->previous_screen_index);
    // Save previous_screen_index after all checks are done.
    context->previous_screen_index = msg->screenIndex;
    // Scroll to next screen
    if (scroll_direction == RIGHT_SCROLL)
        skip_right(context);
    else
        skip_left(context);
}

void handle_query_contract_ui(void *parameters)
{
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
    memset(msg->msg, 0, msg->msgLength);

    get_screen_array(msg, context);
    print_screen_array(context);

    msg->result = ETH_PLUGIN_RESULT_OK;
    switch (context->plugin_screen_index)
    {
    case FIRST_SCREEN_UI:
        set_sent_tokens_ui(msg, context);
        break;
    case SCREEN_2_UI:
        set_received_tokens_ui(msg, context);
        break;
    // case SCREEN_4_UI:
    // set_screen_4_ui(msg, context);
    // break;
    default:
        PRINTF("AN ERROR OCCURED IN UI\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
