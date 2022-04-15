#include "nested_plugin.h"

static void print_booleans(context_t *context)
{
    PRINTF("IS_COPY %d\n", context->booleans & IS_COPY);
    PRINTF("TOKEN1_FOUND %d\n", context->booleans & TOKEN1_FOUND);
    PRINTF("TOKEN2_FOUND %d\n", context->booleans & TOKEN2_FOUND);
    PRINTF("IS_FROM_RESERVE %d\n", context->booleans & IS_FROM_RESERVE);
    PRINTF("BOOL5 %d\n", context->booleans & BOOL5);
    PRINTF("BOOL6 %d\n", context->booleans & BOOL6);
    PRINTF("BOOL7 %d\n", context->booleans & BOOL7);
    PRINTF("BOOL8 %d\n", context->booleans & BOOL8);
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
            break;
        }
        break;
    case CREATE:
    case DESTROY:
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
    if (!ADDRESS_IS_NETWORK_TOKEN(context->token2_address) && !ADDRESS_IS_NULL_ADDRESS(context->token2_address))
    {
        // Address is not network token (0xeee...) or null so we will need to look up the token.
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

    print_booleans(context);

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->result = ETH_PLUGIN_RESULT_OK;
}
