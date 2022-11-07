#include "nested_plugin.h"

/**
 * Get the ui selector added by Nested front-end
 * @return first byte found
 */
static uint8_t get_ui_selector(const uint8_t *parameter) {
    uint8_t i = 0;
    while (parameter[i] == 0 && i < PARAMETER_LENGTH) i++;
    return parameter[i];
}

/**
 * parse order struct
 */
void parse_order(ethPluginProvideParameter_t *msg, context_t *context) {
    // is on last tx param, where we can find ui_selector.
    if (context->last_calldata_offset == msg->parameterOffset) {
        context->ui_selector = get_ui_selector(msg->parameter);
        PRINTF("copied ui_selector: %d\n", context->ui_selector);
        PRINTF("last_calldata_offset: %d\n", context->last_calldata_offset);
        return;
    }
    // is on beginning of last order, reset next_param for parsing purposes.
    if (context->target_offset == msg->parameterOffset) {
        PRINTF("START LAST ORDER\n");
        context->next_param = (order) ORDER__OPERATOR;
    }
    switch ((order) context->next_param) {
        case ORDER__OPERATOR:
            PRINTF("parse ORDER__OPERATOR\n");
            context->current_tuple_offset = 0;
            if (add_numbers(&context->current_tuple_offset, msg->parameterOffset)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_tuple_offset: %d\n", context->current_tuple_offset);
            context->next_param = (order) ORDER__TOKEN_ADDRESS;
            break;
        case ORDER__TOKEN_ADDRESS:
            PRINTF("parse ORDER__TOKEN_ADDRESS\n");
            if (context->number_of_tokens == 1) {
                // is processOutput
                if (context->selectorIndex == PROCESS_OUTPUT_ORDERS) {
                    copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
                    PRINTF("Copied to token1_address: %.*H\n",
                           ADDRESS_LENGTH,
                           context->token1_address);
                }
                // is create, processInput or destroy
                else {
                    copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
                    PRINTF("Copied to token2_address: %.*H\n",
                           ADDRESS_LENGTH,
                           context->token2_address);
                }
            }
            context->next_param = (order) ORDER__OFFSET_CALLDATA;
            break;
        case ORDER__OFFSET_CALLDATA:
            PRINTF("parse ORDER__OFFSET_CALLDATA\n");
            context->next_param = (order) ORDER__LEN_CALLDATA;
            break;
        case ORDER__LEN_CALLDATA:
            PRINTF("parse ORDER__LEN_CALLDATA\n");
            // is on last order ?
            if (msg->parameterOffset > context->target_offset) {
                // get the offset of the last calldata to parse last Tx's byte
                if (copy_number(&context->last_calldata_offset, msg->parameter, PARAMETER_LENGTH)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                if (add_numbers(&context->last_calldata_offset,
                                msg->parameterOffset + PARAMETER_LENGTH)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                PRINTF("setting last_calldata_offset: %d\n", context->last_calldata_offset);
            }
            context->next_param = (order) ORDER__CALLDATA;
            break;
        case ORDER__CALLDATA:
            break;
        default:
            PRINTF("order's param not supported: %d\n", context->next_param);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

/**
 * parse batch_output_orders struct
 * token2 is the output token
 */
void parse_batched_output_orders(ethPluginProvideParameter_t *msg, context_t *context) {
    switch ((batch_output_orders) context->next_param) {
        case BOO__OUTPUTTOKEN:
            PRINTF("parse BOO__OUTPUTTOKEN\n");
            copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
            PRINTF("copie token2 address: %.*H\n", ADDRESS_LENGTH, context->token2_address);
            context->current_tuple_offset = 0;
            if (add_numbers(&context->current_tuple_offset, msg->parameterOffset)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_tuple_offset: %d\n", context->current_tuple_offset);
            context->next_param = (batch_output_orders) BOO__OFFSET_AMOUNTS;
            break;
        case BOO__OFFSET_AMOUNTS:
            PRINTF("parse BOO__OFFSET_AMOUNTS\n");
            context->next_param = (batch_output_orders) BOO__OFFSET_ORDERS;
            break;
        case BOO__OFFSET_ORDERS:
            PRINTF("parse BOO__OFFSET_ORDERS\n");
            context->next_param = (batch_output_orders) BOO__FROM_RESERVE;
            break;
        case BOO__FROM_RESERVE:
            PRINTF("parse BOO__FROM_RESERVE\n");
            context->next_param = (batch_output_orders) BOO__LEN_AMOUNTS;
            break;
        case BOO__LEN_AMOUNTS:
            PRINTF("parse BOO__LEN_AMOUNTS\n");
            if (copy_number(&context->current_length, msg->parameter, PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_length: %d\n", context->current_length);
            context->next_param = (batch_output_orders) BOO__AMOUNT;
            break;
        case BOO__AMOUNT:
            PRINTF("parse BOO__AMOUNT, index: %d\n", context->current_length);
            // copy last amount, matching b2c
            if (context->current_length == 1) {
                copy_parameter(context->token1_amount,
                               msg->parameter,
                               sizeof(context->token1_amount));
                PRINTF("copie token1 amount: %.*H\n", PARAMETER_LENGTH, context->token1_amount);
            }
            if (context->current_length) context->current_length--;
            // skip until last amount
            if (context->current_length == 0)
                context->next_param = (batch_output_orders) BOO__LEN_ORDERS;
            break;
        case BOO__LEN_ORDERS:
            PRINTF("parse BOO__LEN_ORDERS\n");
            if (copy_number(&context->current_length, msg->parameter, PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_length: %d\n", context->current_length);
            if (copy_number(&context->number_of_tokens, msg->parameter, PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting number_of_tokens: %d\n", context->number_of_tokens);
            context->current_tuple_offset = 0;
            if (add_numbers(&context->current_tuple_offset,
                            msg->parameterOffset + PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_tuple_offset: %d\n", context->current_tuple_offset);
            context->next_param = (batch_output_orders) BOO__OFFSET_ARRAY_ORDERS;
            break;
        case BOO__OFFSET_ARRAY_ORDERS:
            PRINTF("parse BOO__OFFSET_ARRAY_ORDERS, index: %d\n", context->current_length);
            if (context->current_length) context->current_length--;
            // copy last order, matching b2c
            if (context->current_length == 0) {
                PRINTF("parse BOO__OFFSET_ARRAY_ORDERS LAST\n");
                // Copy targeted offset
                if (copy_number(&context->target_offset, msg->parameter, PARAMETER_LENGTH)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                // add current depth offset to target offset
                if (add_numbers(&context->target_offset, context->current_tuple_offset)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                PRINTF("target_offset: %d\n", context->target_offset);
                // Switch to order's parsing
                context->on_struct = (on_struct) S_ORDER;
                context->next_param = (order) ORDER__OPERATOR;
            }
            break;
        default:
            PRINTF("batch_output_orders's param not supported: %d\n", context->next_param);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

/**
 * parse batched_input_orders struct
 */
void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context) {
    PRINTF("PARSING BIO step; %d\n", context->next_param);
    switch ((batch_input_orders) context->next_param) {
        case BIO__INPUTTOKEN:
            PRINTF("parse BIO__INPUTTOKEN\n");
            copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
            PRINTF("Copied inputToken to token1_address: %.*H\n",
                   ADDRESS_LENGTH,
                   context->token1_address);
            // Set current_tuple_offset for parsing purposes
            context->current_tuple_offset = msg->parameterOffset;
            PRINTF("parse BIO__INPUTTOKEN, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
            context->next_param = (batch_input_orders) BIO__AMOUNT;
            break;
        case BIO__AMOUNT:
            PRINTF("parse BIO__AMOUNT\n");
            copy_parameter(context->token1_amount, msg->parameter, sizeof(context->token1_amount));
            PRINTF("get token1_amount: %.*H\n", PARAMETER_LENGTH, context->token1_amount);
            context->next_param = (batch_input_orders) BIO__OFFSET_ORDERS;
            break;
        case BIO__OFFSET_ORDERS:
            PRINTF("parse BIO__OFFSET_ORDERS\n");
            context->next_param = (batch_input_orders) BIO__FROM_RESERVE;
            break;
        case BIO__FROM_RESERVE:
            PRINTF("parse BIO__FROM_RESERVE\n");
            context->next_param = (batch_input_orders) BIO__LEN_ORDERS;
            break;
        case BIO__LEN_ORDERS:
            PRINTF("parse BIO__LEN_ORDERS\n");
            if (copy_number(&context->number_of_tokens, msg->parameter, PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting number_of_tokens: %d\n", context->number_of_tokens);
            if (copy_number(&context->current_length, msg->parameter, PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_length: %d\n", context->current_length);
            context->current_tuple_offset = 0;
            if (add_numbers(&context->current_tuple_offset,
                            msg->parameterOffset + PARAMETER_LENGTH)) {
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                return;
            }
            PRINTF("setting current_tuple_offset: %d\n", context->current_tuple_offset);
            context->next_param = (batch_input_orders) BIO__OFFSET_ARRAY_ORDERS;
            break;
        case BIO__OFFSET_ARRAY_ORDERS:
            PRINTF("parse BIO__OFFSET_ARRAY_ORDERS\n");
            if (context->current_length) context->current_length--;
            // is on last order's offset to match b2c
            if (context->current_length == 0) {
                PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
                if (copy_number(&context->target_offset, msg->parameter, PARAMETER_LENGTH)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                if (add_numbers(&context->target_offset, context->current_tuple_offset)) {
                    msg->result = ETH_PLUGIN_RESULT_ERROR;
                    return;
                }
                PRINTF("target_offset: %d\n", context->target_offset);
                // Switch to order's parsing
                context->on_struct = (on_struct) S_ORDER;
                context->next_param = (order) ORDER__OPERATOR;
            }
            break;
        default:
            PRINTF("batch_input_orders's param not supported: %d\n", context->next_param);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}
