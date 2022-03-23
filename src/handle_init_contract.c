#include "nested_plugin.h"

static int find_selector(uint32_t selector, const uint32_t *selectors, size_t n, selector_t *out)
{
    for (selector_t i = 0; i < n; i++)
    {
        if (selector == selectors[i])
        {
            *out = i;
            return 0;
        }
    }
    return -1;
}

// Called once to init.
void handle_init_contract(void *parameters)
{
    PRINTF("IN handle_init_contract\n");
    // Cast the msg to the type of structure we expect (here, ethPluginInitContract_t).
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *)parameters;

    // Make sure we are running a compatible version.
    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST)
    {
        // If not the case, return the `UNAVAILABLE` status.
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    // Double check that the `context_t` struct is not bigger than the maximum size (defined by
    // `msg->pluginContextLength`).
    if (msg->pluginContextLength < sizeof(context_t))
    {
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    context_t *context = (context_t *)msg->pluginContext;

    // Initialize the context (to 0).
    memset(context, 0, sizeof(*context));
    context->current_tuple_offset = SELECTOR_SIZE;

    uint32_t selector = U4BE(msg->selector, 0);
    if (find_selector(selector, NESTED_SELECTORS, NUM_SELECTORS, &context->selectorIndex))
    {
        PRINTF("can't find selector\n");
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    // Set `next_param` to be the first field we expect to parse.
    switch (context->selectorIndex)
    {
    case CREATE:
        PRINTF("IN CREATE\n");
        context->next_param = CREATE__TOKEN_ID;
        break;
    case PROCESS_INPUT_ORDERS:
        PRINTF("IN PROCESS_INPUT_ORDERS\n");
        context->next_param = CREATE__TOKEN_ID; //// ??
        break;
    case PROCESS_OUTPUT_ORDERS:
        PRINTF("IN PROCESS_OUTPUT_ORDERS\n");
        context->next_param = CREATE__TOKEN_ID; /// ??
        break;
    case DESTROY:
        PRINTF("IN DESTROY\n");
        context->next_param = CREATE__TOKEN_ID; /// ? PARAMS TO BE MODIFIED
        break;
    case RELEASE_TOKENS:
        PRINTF("IN RELEASE TOKENS\n");
        context->next_param = RELEASE_OFFSET_TOKENS;
        break;
    case TRANSFER_FROM:
        PRINTF("IN TRANSFER FROM\n");
        context->next_param = CREATE__TOKEN_ID; /// ? PARAMS TO BE MODIFIED
        break;
    // Keep this
    default:
        PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    // Return valid status.
    msg->result = ETH_PLUGIN_RESULT_OK;
}
