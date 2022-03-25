#include "nested_plugin.h"

static uint8_t count_screens(uint8_t screen_array)
{
    uint8_t total = 0;
    uint8_t scout = 1;
    for (uint8_t i = 0; i < 8; i++)
    {
        if (scout & screen_array)
            total++;
        scout <<= 1;
    }
    return total;
}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    context->screen_array |= TX_TYPE_UI;
    context->screen_array |= PLACEHOLDER_UI;

    // Look for payment token info

    //// set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    //// token addresses you will info for (such as decimals, ticker...)
    msg->tokenLookup1 = context->payment_token_address;

    // set the first screen to display.
    context->plugin_screen_index = TX_TYPE_UI;
    context->payment_token_decimals = DEFAULT_DECIMAL;
    //// set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    //// token addresses you will info for (such as decimals, ticker...).

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->numScreens = count_screens(context->screen_array);
    msg->result = ETH_PLUGIN_RESULT_OK;
}
