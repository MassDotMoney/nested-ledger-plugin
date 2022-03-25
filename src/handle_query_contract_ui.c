#include "nested_plugin.h"
#include "text.h"

static void set_tx_type_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (context->selectorIndex)
    {
    case CREATE:
        strlcpy(msg->title, TITLE_CREATE, msg->titleLength);
        strlcpy(msg->msg, MSG_CREATE, msg->msgLength);
        break;
    default:
        break;
    }
}

static void set_placeholder_ui(ethQueryContractUI_t *msg, context_t *context)
{
    switch (context->selectorIndex)
    {
    case CREATE:
        strlcpy(msg->title, TITLE_PLACEHOLDER, msg->titleLength);
        strlcpy(msg->msg, MSG_PLACEHOLDER, msg->msgLength);
        break;
    default:
        break;
    }
}

// Set UI for "Warning" screen.
static void set_token_warning_ui(ethQueryContractUI_t *msg,
                                 context_t *context __attribute__((unused)))
{
    strlcpy(msg->title, TITLE_UNKNOWN_PAYMENT_TOKEN, msg->titleLength);
    strlcpy(msg->msg, MSG_UNKNOWN_PAYMENT_TOKEN, msg->titleLength);
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
        context->plugin_screen_index = TX_TYPE_UI;
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

    // msg->title is the upper line displayed on the device.
    // msg->msg is the lower line displayed on the device.

    // Clean the display fields.
    memset(msg->title, 0, msg->titleLength);
    memset(msg->msg, 0, msg->msgLength);

    get_screen_array(msg, context);
    msg->result = ETH_PLUGIN_RESULT_OK;
    switch (context->plugin_screen_index)
    {
    case TX_TYPE_UI:
        set_tx_type_ui(msg, context);
        break;
    case PLACEHOLDER_UI:
        set_placeholder_ui(msg, context);
        break;
    case UNKNOWN_PAYMENT_TOKEN_UI:
        set_token_warning_ui(msg, context);
        break;
    default:
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
}
