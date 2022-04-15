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

    // set default decimals
    context->token1_decimals = DEFAULT_DECIMAL;

    // Determine screens count.
    switch ((selector_t)context->selectorIndex)
    {
    case RELEASE_TOKENS:
    case TRANSFER_FROM:
        msg->numScreens = 1;
        break;
    case CREATE:
    case DESTROY:
        msg->numScreens = 2;
        break;
    case PROCESS_INPUT_ORDERS:
    case PROCESS_OUTPUT_ORDERS:
        switch ((ui_selector)context->ui_selector)
        {
        case DEPOSIT:
        case WITHDRAW:
        case SYNCHRONIZATION:
            msg->numScreens = 1;
            break;
        case ADD_TOKENS:
        case SELL_TOKENS:
        case SWAP:
            msg->numScreens = 2;
            break;
        case NONE:
            PRINTF("Error: could not find ui selector.\n");
            msg->numScreens = 2;
            break;
        }
        break;
    }

    // Check if token1 is (0xeee...)
    if (ADDRESS_IS_NETWORK_TOKEN(context->token1_address))
        context->booleans |= TOKEN1_FOUND;
    else
    {
        PRINTF("Setting address to: %.*H\n",
               ADDRESS_LENGTH,
               context->token1_address);
        // Address is not network token (0xeee...) so we will need to look up the token.
        msg->tokenLookup1 = context->token1_address;
    }

    // Check if token1 is (0xeee...) or (0x000...)
    if (ADDRESS_IS_NETWORK_TOKEN(context->token1_address) || ADDRESS_IS_NULL_ADDRESS(context->token2_address))
        context->booleans |= TOKEN2_FOUND;
    else
    {
        PRINTF("Setting token2 address to: %.*H\n",
               ADDRESS_LENGTH,
               context->token2_address);
        // Address is not network token (0xeee...) or null so we will need to look up the token.
        msg->tokenLookup2 = context->token2_address;
    }

    print_booleans(context);

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->result = ETH_PLUGIN_RESULT_OK;
}
