#include "nested_plugin.h"

static void check_token_id(ethPluginProvideParameter_t *msg, context_t *context)
{
    for (uint8_t i = 0; i < PARAMETER_LENGTH; i++)
    {
        if (msg->parameter[i] != 0)
        {
            PRINTF("IS NOT 0\n");
            context->booleans |= IS_COPY;
            break;
        }
    }
}

// processInputOrder as the same signature
static void handle_create(ethPluginProvideParameter_t *msg, context_t *context)
{
    if (context->on_struct)
    {
        if (context->on_struct == S_BATCHED_INPUT_ORDERS)
            parse_batched_input_orders(msg, context);
        else if (context->on_struct == S_BATCHED_OUTPUT_ORDERS)
            parse_batched_output_orders(msg, context);
        else if (context->on_struct == S_ORDER)
            parse_order(msg, context);
        else
        {
            PRINTF("handle_create on_struct ERROR\n");
            msg->result = ETH_PLUGIN_RESULT_ERROR;
        }
        return;
    }
    PRINTF("PARSING CREATE\n");
    switch ((create_parameter)context->next_param)
    {
    case CREATE__TOKEN_ID:
        PRINTF("CREATE__TOKEN_ID\n");
        if (context->selectorIndex == CREATE)
            check_token_id(msg, context);
        break;
    case CREATE__OFFSET_BIO:
        PRINTF("CREATE__OFFSET_BIO\n");
        copy_offset(msg, context); // osef
        break;
    case CREATE__LEN_BIO:
        PRINTF("CREATE__LEN_BIO\n");
        context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        PRINTF("current_length: %d\n", context->current_length);
        break;
    case CREATE__OFFSET_ARRAY_BIO:
        context->length_offset_array--;
        PRINTF("CREATE__OFFSET_ARRAY_BIO, index: %d\n",
               context->length_offset_array);
        if (context->length_offset_array < 2)
        {
            context->offsets_lvl0[context->length_offset_array] =
                U4BE(msg->parameter, PARAMETER_LENGTH - 4);
            PRINTF("offsets_lvl0[%d]: %d\n",
                   context->length_offset_array,
                   context->offsets_lvl0[context->length_offset_array]);
        }
        if (context->length_offset_array == 0)
        {
            switch (context->selectorIndex)
            {
            case CREATE:
            case PROCESS_INPUT_ORDERS:
                context->on_struct = (on_struct)S_BATCHED_INPUT_ORDERS;
                context->next_param = (batch_input_orders)BIO__INPUTTOKEN;
                break;
            case PROCESS_OUTPUT_ORDERS:
                context->on_struct = (on_struct)S_BATCHED_OUTPUT_ORDERS;
                context->next_param = (batch_input_orders)BOO__OUTPUTTOKEN;
                break;
            default:
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
            }
        }
        return;
    case CREATE__BIO:
        PRINTF("NOP NOP CREATE__BIO\n");
        return;
    default:
        PRINTF("Param not supported: %d\n", context->next_param);
        msg->result = ETH_PLUGIN_RESULT_ERROR;
        break;
    }
    context->next_param++;
}

static void handle_release_tokens(ethPluginProvideParameter_t *msg, context_t *context)
{
    PRINTF("HANDLE_RELEASE_TOKENS\n");
    switch ((release_tokens_paramter)context->next_param)
    {
    case RELEASE_OFFSET_TOKENS:
        PRINTF("RELEASE_OFFSET_TOKENS\n");
        context->next_param++;
        break;
    case RELEASE_LEN_TOKENS:
        PRINTF("RELEASE_LEN_TOKENS\n");
        context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
        context->number_of_tokens = context->current_length;
        context->next_param++;
        break;
    case RELEASE_ARRAY_TOKENS:
        // is first elem
        if (context->number_of_tokens == context->current_length)
        {
            PRINTF("RELEASE copy first\n");
            copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
        }
        context->current_length--;
        // is last elem && multiple tokens
        if (context->number_of_tokens > 1 && context->current_length == 0)
        {
            PRINTF("RELEASE copy last\n");
            copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
        }
        PRINTF("RELEASE_TOKENS %d\n", context->current_length);
        break;
    }
}

void handle_provide_parameter(void *parameters)
{
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;
    // We use `%.*H`: it's a utility function to print bytes. You first give
    // the number of bytes you wish to print (in this case, `PARAMETER_LENGTH`) and then
    // the address (here `msg->parameter`).
    PRINTF("___\nplugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
           msg->parameterOffset,
           PARAMETER_LENGTH,
           msg->parameter);

    msg->result = ETH_PLUGIN_RESULT_OK;

    switch (context->selectorIndex)
    {
    case CREATE:
    case PROCESS_INPUT_ORDERS:
    case PROCESS_OUTPUT_ORDERS:
        handle_create(msg, context);
        break;
    case DESTROY:
        // handle_destroy(msg, context);
        break;
    case RELEASE_TOKENS:
        handle_release_tokens(msg, context);
        break;
    default:
        PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
        // msg->result = ETH_PLUGIN_RESULT_ERROR;
        msg->result = ETH_PLUGIN_RESULT_OK; // !!! TODO should be error.
        break;
    }
}