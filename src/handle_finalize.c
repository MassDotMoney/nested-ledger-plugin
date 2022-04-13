#include "nested_plugin.h"

static void print_booleans(context_t *context)
{
    PRINTF("IS_COPY %d\n", context->screen_array & IS_COPY);
    PRINTF("TOKEN1_FOUND %d\n", context->screen_array & TOKEN1_FOUND);
    PRINTF("TOKEN2_FOUND %d\n", context->screen_array & TOKEN2_FOUND);
    PRINTF("IS_FROM_RESERVE %d\n", context->screen_array & IS_FROM_RESERVE);
    PRINTF("BOOL5 %d\n", context->screen_array & BOOL5);
    PRINTF("BOOL6 %d\n", context->screen_array & BOOL6);
    PRINTF("BOOL7 %d\n", context->screen_array & BOOL7);
    PRINTF("BOOL8 %d\n", context->screen_array & BOOL8);
}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    context->token1_decimals = DEFAULT_DECIMAL;
    msg->numScreens = 2;

    switch (context->selectorIndex)
    {
    case RELEASE_TOKENS:
        if (context->number_of_tokens != 2)
            msg->numScreens = 1;
        break;
    case TRANSFER_FROM:
        msg->numScreens = 1;
        break;
    case PROCESS_INPUT_ORDERS:
    case PROCESS_OUTPUT_ORDERS:
        switch (context->ui_selector)
        {
        case DEPOSIT:
        case WITHDRAW:
        case SYNCHRONIZATION:
            msg->numScreens = 1;
            break;
        default:
            PRINTF("GPIRIOU DEFAULT FINALIZE\n");
            break;
        }
        break;
    }
    //// set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    //// token addresses you will info for (such as decimals, ticker...).
    if (!ADDRESS_IS_NETWORK_TOKEN(context->token1_address))
    {
        // Address is not network token (0xeee...) so we will need to look up the token in the
        // CAL.
        PRINTF("Setting address to: %.*H\n",
               ADDRESS_LENGTH,
               context->token1_address);
        msg->tokenLookup1 = context->token1_address;
    }
    else
    {
        context->booleans |= TOKEN1_FOUND;
        msg->tokenLookup2 = NULL;
    }
    if (!ADDRESS_IS_NETWORK_TOKEN(context->token2_address))
    {
        // Address is not network token (0xeee...) so we will need to look up the token in the
        // CAL.
        PRINTF("Setting token2 address to: %.*H\n",
               ADDRESS_LENGTH,
               context->token2_address);
        msg->tokenLookup2 = context->token2_address;
    }
    else
    {
        context->booleans |= TOKEN2_FOUND;
        msg->tokenLookup2 = NULL;
    }
    //if (memcmp(context->token1_address, NULL_ADDRESS, ADDRESS_LENGTH))
    //    msg->tokenLookup1 = context->token1_address;
    //if (memcmp(context->token2_address, NULL_ADDRESS, ADDRESS_LENGTH))
    //    msg->tokenLookup2 = context->token2_address;

    print_booleans(context);

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->result = ETH_PLUGIN_RESULT_OK;
}
