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

    if (context->selectorIndex == CREATE) {
        PRINTF("context->booleans & IS_COPY: %d\n", context->booleans & IS_COPY);
        if (context->booleans & IS_COPY)
            strlcpy(msg->version, "Copy", msg->versionLength);
        else
            strlcpy(msg->version, "Create", msg->versionLength);
        msg->result = ETH_PLUGIN_RESULT_OK;
    } else {
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
    }
}