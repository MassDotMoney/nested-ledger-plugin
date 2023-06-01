#include "nested_plugin.h"

void handle_finalize(void *parameters) {
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    // set default decimals
    context->token1_decimals = DEFAULT_DECIMAL;
    // set default numScreens
    msg->numScreens = 2;

    // Determine screens count.
    switch ((selector_t) context->selectorIndex) {
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
            switch ((ui_selector) context->ui_selector) {
                case SYNC:
                case EDIT_ALLOC:
                case DEPOSIT:
                case WITHDRAW:
                case PROPO_WITHDRAWAL:
                case PROPO_DEPOSIT:
                    msg->numScreens = 1;
                    break;
                case ADD:
                    msg->numScreens = 2;
                    break;
                case SELL:
                    msg->numScreens = 2;
                    break;
                case SWAP:
                    if (context->number_of_tokens > 1) {
                        PRINTF("Error: too many tokens for SWAP\n");
                        msg->result = ETH_PLUGIN_RESULT_ERROR;
                        return;
                    }
                    msg->numScreens = 2;
                    break;
                case NONE:
                default:
                    PRINTF("Error: could not find ui selector.\n");
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
            }
            break;
        default:
            PRINTF("Param not supported: %d\n", context->next_param);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }

    // Check if token1 is (0xeee...)
    if (ADDRESS_IS_NETWORK_TOKEN(context->token1_address)) context->booleans |= TOKEN1_FOUND;
    // Address is not network token (0xeee...) so we will need to look up the
    // token.
    else {
        PRINTF("Setting tokenLookup1 to: %.*H\n", ADDRESS_LENGTH, context->token1_address);
        msg->tokenLookup1 = context->token1_address;
    }

    // Check if token2 is (0xeee...)
    if (ADDRESS_IS_NETWORK_TOKEN(context->token2_address)) context->booleans |= TOKEN2_FOUND;
    // Address is not network token (0xeee...) or null so we will need to look up
    // the token.
    else {
        PRINTF("Setting tokenLookup2 to: %.*H\n", ADDRESS_LENGTH, context->token2_address);
        msg->tokenLookup2 = context->token2_address;
    }

    PRINTF("Booleans:\n");
    PRINTF("IS_COPY %d\n", context->booleans & IS_COPY);
    PRINTF("TOKEN1_FOUND %d\n", context->booleans & TOKEN1_FOUND);
    PRINTF("TOKEN2_FOUND %d\n", context->booleans & TOKEN2_FOUND);

    PRINTF("\nnumber_of_tokens: %d\n", context->number_of_tokens);
    PRINTF("token1_amount: %.*H\n", sizeof(context->token1_amount), context->token1_amount);

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->result = ETH_PLUGIN_RESULT_OK;
}
