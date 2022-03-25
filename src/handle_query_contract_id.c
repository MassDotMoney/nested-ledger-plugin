#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters)
{
    ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
    const context_t *context = (const context_t *)msg->pluginContext;
    // msg->name will be the upper sentence displayed on the screen.
    // msg->version will be the lower sentence displayed on the screen.

    // For the first screen, display the plugin name.
    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);

    switch (context->selectorIndex)
    {
    case CREATE:
        if (context->booleans & IS_COPY)
            strlcpy(msg->version, MSG_COPY, msg->versionLength);
        else
            strlcpy(msg->version, MSG_CREATE, msg->versionLength);
        break;
    case PROCESS_INPUT_ORDERS:
        strlcpy(msg->version, PROCESS_INPUT_ORDERS, msg->versionLength);
        break;
    case PROCESS_OUTPUT_ORDERS:
        strlcpy(msg->version, PROCESS_OUTPUT_ORDERS, msg->versionLength);
        break;
    case DESTROY:
        strlcpy(msg->version, MSG_DESTROY, msg->versionLength);
        break;
    case RELEASE_TOKENS:
        if (context->current_length > 1)
        {
            strlcpy(msg->version, MSG_CLAIM_ALL, msg->versionLength);
        }
        else
        {
            strlcpy(msg->version, MSG_CLAIM_SINGLE, msg->versionLength);
        }
        break;
    case TRANSFER_FROM:
        strlcpy(msg->version, MSG_TRANSFER_FROM, msg->versionLength);
        break;
    default:
        PRINTF("Selector index: %d not supported\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
}