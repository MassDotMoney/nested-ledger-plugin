#include "nested_plugin.h"
#include "text.h"

static void print_screen_array(context_t *context)
{
    PRINTF("SENT_TOKEN_UI %d\n", context->screen_array & SENT_TOKEN_UI);
    PRINTF("RECEIVED_TOKEN_UI %d\n", context->screen_array & RECEIVED_TOKEN_UI);
    PRINTF("SCREEN_UI_3 %d\n", context->screen_array & SCREEN_UI_3);
    PRINTF("SCREEN_UI_4 %d\n", context->screen_array & SCREEN_UI_4);
    PRINTF("SCREEN_UI_5 %d\n", context->screen_array & SCREEN_UI_5);
    PRINTF("SCREEN_UI_6 %d\n", context->screen_array & SCREEN_UI_6);
    PRINTF("SCREEN_UI_7 %d\n", context->screen_array & SCREEN_UI_7);
    PRINTF("LAST_UI %d\n", context->screen_array & LAST_UI);
}

static void set_sent_token_ui(ethQueryContractUI_t *msg, context_t *context)
{
    PRINTF("PENZO in set_sent_token_ui, on %d selector\n", context->selectorIndex);
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->title, TITLE_COPY_SENT_TOKEN, msg->titleLength);
        else
            strlcpy(msg->title, TITLE_CREATE_SENT_TOKEN, msg->titleLength);
        break;
    case DESTROY:
        strlcpy(msg->title, TITLE_DESTROY_SENT_TOKEN, msg->titleLength);
        strlcpy(msg->msg, MSG_DESTROY_SENT_TOKEN, msg->msgLength);
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

static void set_received_token_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans)
        {
            strlcpy(msg->title, TITLE_COPY_RECEIVED_TOKEN, msg->titleLength);
            strlcpy(msg->msg, MSG_COPY_RECEIVED_TOKEN, msg->msgLength);
        }
        else
        {
            strlcpy(msg->title, TITLE_CREATE_RECEIVED_TOKEN, msg->titleLength);
            strlcpy(msg->msg, MSG_CREATE_RECEIVED_TOKEN, msg->msgLength);
        }
        break;
    case DESTROY:
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
        context->plugin_screen_index = SENT_TOKEN_UI;
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
    case SENT_TOKEN_UI:
        set_sent_token_ui(msg, context);
        break;
    case RECEIVED_TOKEN_UI:
        set_received_token_ui(msg, context);
        break;
    case SCREEN_UI_3:
        set_screen3(msg, context);
        break;
    default:
        PRINTF("AN ERROR OCCURED IN UI\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
