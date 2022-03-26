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

static void set_screens(context_t *context)
{
    switch (context->selectorIndex)
    {
    case RELEASE_TOKENS:
        if (memcmp(context->token1_address, NULL_ADDRESS, ADDRESS_LENGTH))
            context->screen_array |= SENT_TOKEN_UI;
        if (memcmp(context->token2_address, NULL_ADDRESS, ADDRESS_LENGTH))
            context->screen_array |= RECEIVED_TOKEN_UI;
        if (context->number_of_tokens > 2)
            context->screen_array |= SCREEN_UI_3;
        break;
    default:
        PRINTF("set_screens ERROR\n");
    }
}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    set_screens(context);

    // set the first screen to display.
    context->plugin_screen_index = SENT_TOKEN_UI;

    if (memcmp(context->token1_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup1 = context->token1_address;
    if (memcmp(context->token2_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup2 = context->token2_address;

    // set the first screen to display.
    context->plugin_screen_index = SENT_TOKEN_UI;
    context->token1_decimals = DEFAULT_DECIMAL;
    //// set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    //// token addresses you will info for (such as decimals, ticker...).

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->numScreens = count_screens(context->screen_array);
    msg->result = ETH_PLUGIN_RESULT_OK;
}
