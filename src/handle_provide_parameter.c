#include "nested_plugin.h"

void copy_offset(ethPluginProvideParameter_t *msg, context_t *context) {
    PRINTF("msg->parameterOffset: %d\n", msg->parameterOffset);
    uint32_t test = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
    PRINTF("U4BE msg->parameter: %d\n", test);
    context->next_offset = test + context->current_tuple_offset;
    PRINTF("copied offset: %d\n", context->next_offset);
}

static void parse_order(ethPluginProvideParameter_t *msg, context_t *context) {
    PRINTF("PARSING ORDER\n");
    switch ((order) context->next_param) {
        case ORDER__OPERATOR:
            PRINTF("parse ORDER__OPERATOR\n");
            context->current_tuple_offset = msg->parameterOffset;
            PRINTF("NEW current_tuple_offset: %d\n", context->current_tuple_offset);
            break;
        case ORDER__TOKEN_ADDRESS:
            PRINTF("parse ORDER__TOKEN_ADDRESS\n");
            break;
        case ORDER__OFFSET_CALLDATA:
            PRINTF("parse ORDER__OFFSET_CALLDATA\n");
            copy_offset(msg, context);
            break;
        case ORDER__LEN_CALLDATA:
            PRINTF("parse ORDER__LEN_CALLDATA\n");
            break;
        case ORDER__CALLDATA:
            PRINTF("parse ORDER__CALLDATA\n");
            break;
    }
    context->next_param++;
}

static void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context) {
    PRINTF("PARSING BIO step; %d\n", context->next_param);
    switch ((batch_input_orders) context->next_param) {
        case BIO__INPUTTOKEN:
            PRINTF("parse BIO__INPUTTOKEN\n");
            context->current_tuple_offset = msg->parameterOffset;
            break;
        case BIO__AMOUNT:
            PRINTF("parse BIO__AMOUNT\n");
            break;
        case BIO__OFFSET_ORDERS:
            PRINTF("parse BIO__OFFSET_ORDERS\n");
            copy_offset(msg, context);
            break;
        case BIO__FROM_RESERVE:
            PRINTF("parse BIO__FROM_RESERVE\n");
            break;
        case BIO__LEN_ORDERS:
            PRINTF("parse BIO__LEN_ORDERS\n");
            context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
            context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
            PRINTF("current_length: %d\n", context->current_length);
            break;
        case BIO__OFFSET_ARRAY_ORDERS:
            context->length_offset_array--;
            PRINTF("parse BIO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
            if (context->length_offset_array < 2) {
                context->offsets_lvl1[context->length_offset_array] =
                    U4BE(msg->parameter, PARAMETER_LENGTH - 4);
                PRINTF("offsets_lvl1[%d]: %d\n",
                       context->length_offset_array,
                       context->offsets_lvl1[context->length_offset_array]);
            }
            if (context->length_offset_array == 0) {
                PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
                context->on_struct = (on_struct) S_ORDER;
                context->next_param = (batch_input_orders) ORDER__OPERATOR;
            }
            return;
            break;
        default:
            break;
    }
    context->next_param++;
}

static void handle_create(ethPluginProvideParameter_t *msg, context_t *context) {
    if (context->on_struct) {
        switch (context->on_struct) {
            case S_BATCHED_INPUT_ORDERS:
                parse_batched_input_orders(msg, context);
                break;
            // case S_BATCHED_OUTPUT_ORDERS:
            //     break;
            case S_ORDER:
                parse_order(msg, context);
                break;
        }
        return;
    }
    PRINTF("PARSING CREATE\n");
    switch ((create_parameter) context->next_param) {
        case CREATE__TOKEN_ID:
            PRINTF("CREATE__TOKEN_ID\n");
            for (uint8_t i = 0; i < PARAMETER_LENGTH; i++) {
                if (msg->parameter[i] != 0) {
                    PRINTF("IS NOT 0\n");
                    context->booleans |= IS_COPY;
                    break;
                }
            }
            break;
        case CREATE__OFFSET_BATCHINPUTORDER:
            PRINTF("CREATE__OFFSET_BATCHINPUTORDER\n");
            copy_offset(msg, context);  // osef
            break;
        case CREATE__LEN_BATCHINPUTORDER:
            PRINTF("CREATE__LEN_BATCHINPUTORDER\n");
            context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
            context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
            PRINTF("current_length: %d\n", context->current_length);
            break;
        case CREATE__OFFSET_ARRAY_BATCHINPUTORDER:
            context->length_offset_array--;
            PRINTF("CREATE__OFFSET_ARRAY_BATCHINPUTORDER, index: %d\n",
                   context->length_offset_array);
            if (context->length_offset_array < 2) {
                context->offsets_lvl0[context->length_offset_array] =
                    U4BE(msg->parameter, PARAMETER_LENGTH - 4);
                PRINTF("offsets_lvl0[%d]: %d\n",
                       context->length_offset_array,
                       context->offsets_lvl0[context->length_offset_array]);
            }
            if (context->length_offset_array == 0) {
                context->on_struct = (on_struct) S_BATCHED_INPUT_ORDERS;
                context->next_param = (batch_input_orders) BIO__INPUTTOKEN;
            }
            return;
            break;
        case CREATE__BATCH_INPUT_ORDERS:
            PRINTF("NOP NOP CREATE__BATCH_INPUT_ORDERS\n");
            return;
            break;
        default:
            PRINTF("Param not supported: %d\n", context->next_param);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
    context->next_param++;
}

void handle_provide_parameter(void *parameters) {
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
    // We use `%.*H`: it's a utility function to print bytes. You first give
    // the number of bytes you wish to print (in this case, `PARAMETER_LENGTH`) and then
    // the address (here `msg->parameter`).
    PRINTF("plugin provide parameter: offset %d\nBytes: \033[0;31m %.*H \033[0m \n",
           msg->parameterOffset,
           PARAMETER_LENGTH,
           msg->parameter);

    msg->result = ETH_PLUGIN_RESULT_OK;

    switch (context->selectorIndex) {
        case CREATE:
            handle_create(msg, context);
            break;
        default:
            PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}