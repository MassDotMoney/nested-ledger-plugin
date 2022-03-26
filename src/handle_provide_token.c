#include "nested_plugin.h"

// EDIT THIS: Adapt this function to your needs! Remember, the information for tokens are held in
// `msg->token1` and `msg->token2`. If those pointers are `NULL`, this means the ethereum app didn't
// find any info regarding the requested tokens!
void handle_provide_token(void *parameters)
{
    ethPluginProvideInfo_t *msg = (ethPluginProvideInfo_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    if (msg->item1)
    {
        PRINTF("handle_provide_token item1\n");

        // The Ethereum App found the information for the requested token!
        context->booleans |= TOKEN1_FOUND;

        // Store its decimals.
        context->token1_decimals = msg->item1->token.decimals;

        // Store its ticker.
        strlcpy(context->token1_ticker, (char *)msg->item1->token.ticker, sizeof(context->token1_ticker));
    }
    else
    {
        PRINTF("handle_provide_token no item1\n");

        // If we wanted to add a screen, say a warning screen for example, we could instruct the
        // ethereum app to add an additional screen by setting `msg->additionalScreens` here, just
        // like so:
        context->screen_array |= SCREEN_UI_3; // nop
        msg->additionalScreens++;
    }
    if (msg->item2)
    {
        PRINTF("handle_provide_token item2\n");
        context->booleans |= TOKEN2_FOUND;
        // context->token2_decimals = msg->item2->token.decimals;
        strlcpy(context->token2_ticker, (char *)msg->item2->token.ticker, sizeof(context->token2_ticker));
    }
    else
    {
        PRINTF("handle_provide_token no item2\n");
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
}