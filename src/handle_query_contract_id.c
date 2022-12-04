#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters) {
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    const context_t *context = (const context_t *) msg->pluginContext;
    // msg->name will be the upper sentence displayed on the screen.
    // msg->version will be the lower sentence displayed on the screen.

    // For the first screen, display the plugin name.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);

    // Get selector according screen.
    switch (context->selectorIndex) {
        case CREATE:
            if (context->booleans & IS_COPY)
                strlcpy(msg->version, "Replicate a Portfolio", msg->versionLength);
            else
                strlcpy(msg->version, "Create Portfolio", msg->versionLength);
            break;
        case PROCESS_INPUT_ORDERS:
        case PROCESS_OUTPUT_ORDERS:
            if (context->ui_selector == ADD)
                strlcpy(msg->version, "Buy", msg->versionLength);
            else if (context->ui_selector == DEPOSIT)
                strlcpy(msg->version, "Simple Deposit", msg->versionLength);
            else if (context->ui_selector == SYNC || context->ui_selector == NOOP ||
                     context->ui_selector == SEND || context->ui_selector == EDIT_ALLOC)
                ;  // no bottom screen
            else if (context->ui_selector == SELL)
                strlcpy(msg->version, "Sell", msg->versionLength);
            else if (context->ui_selector == WITHDRAW)
                strlcpy(msg->version, "Simple Withdraw", msg->versionLength);
            else if (context->ui_selector == SWAP)
                strlcpy(msg->version, "Convert", msg->versionLength);
            else if (context->ui_selector == PROPO_WITHDRAWAL)
                strlcpy(msg->version, "Proportional Withdrawal", msg->versionLength);
            else if (context->ui_selector == PROPO_DEPOSIT)
                strlcpy(msg->version, "Proportional Deposit", msg->versionLength);
            else if (context->ui_selector == BURN)
                strlcpy(msg->version, "Sell all Portfolio", msg->versionLength);
            else {
                PRINTF("ui_selector: %d not supported\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            break;
        case DESTROY:
            strlcpy(msg->version, "Sell Portfolio", msg->versionLength);
            break;
        case RELEASE_TOKENS:
            strlcpy(msg->version, "Claim Royalties", msg->versionLength);
            break;
        case TRANSFER_FROM:
            strlcpy(msg->version, "Send Portfolio", msg->versionLength);
            break;
        default:
            PRINTF("Selector index: %d not supported\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
}
