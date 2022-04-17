#include "nested_plugin.h"

/**
 * Get the ui selector added by Nested front-end
 * @return parsed byte
 */
static uint8_t get_ui_selector(const uint8_t *parameter)
{
	uint8_t i = 0;
	while (parameter[i] == 0 && i < PARAMETER_LENGTH)
		i++;
	return parameter[i];
}

/**
 * parse order struct
 */
void parse_order(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("LAST CALLDATA OFFSET: %d\n", context->last_calldata_offset);
	// is on last tx param.
	if (context->last_calldata_offset == msg->parameterOffset)
	{
		context->ui_selector = get_ui_selector(msg->parameter);
		PRINTF("copied ui_selector: %d\n", context->ui_selector);
		return;
	}
	// is on the last order, reset next_param for parsing purposes.
	if (context->offsets_lvl1 == msg->parameterOffset)
	{
		PRINTF("START LAST ORDER\n");
		context->next_param = (order)ORDER__OPERATOR;
	}
	PRINTF("PARSING ORDER with next->param: %d\n", context->next_param);
	switch ((order)context->next_param)
	{
	case ORDER__OPERATOR:
		PRINTF("parse ORDER__OPERATOR\n");
		context->current_tuple_offset = msg->parameterOffset;
		PRINTF("NEW current_tuple_offset: %d\n", context->current_tuple_offset);
		break;
	case ORDER__TOKEN_ADDRESS:
		PRINTF("parse ORDER__TOKEN_ADDRESS\n");
		if (context->number_of_tokens == 1)
		{
			if (context->selectorIndex == PROCESS_OUTPUT_ORDERS)
			{
				PRINTF("copie token1 address\n");
				copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
			}
			else
			{
				PRINTF("copie token2 address\n");
				copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
			}
		}
		break;
	case ORDER__OFFSET_CALLDATA:
		PRINTF("parse ORDER__OFFSET_CALLDATA\n");
		break;
	case ORDER__LEN_CALLDATA:
		PRINTF("parse ORDER__LEN_CALLDATA\n");
		// is on last order ???
		if (msg->parameterOffset > context->offsets_lvl1)
		{
			// get last_calldata_offset to parse last Tx's byte
			context->last_calldata_offset = msg->parameterOffset + PARAMETER_LENGTH + U4BE(msg->parameter, PARAMETER_LENGTH - 4);
			PRINTF("LAST ORDER offset: %d\n", context->last_calldata_offset);
		}
		break;
	case ORDER__CALLDATA:
		PRINTF("parse TEST ORDER__CALLDATA start\n");
		return;
	default:
		PRINTF("Param not supported: %d\n", context->next_param);
		msg->result = ETH_PLUGIN_RESULT_ERROR;
		break;
	}
	context->next_param++;
}

/**
 * parse batch_output_orders struct
 * token2 is the output token
 */
void parse_batched_output_orders(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("PARSING BOO step; %d\n", context->next_param);
	switch ((batch_output_orders)context->next_param)
	{
	case BOO__OUTPUTTOKEN:
		PRINTF("parse BOO__OUTPUTTOKEN\n");
		copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
		PRINTF("copie token2 address: %.*H\n", ADDRESS_LENGTH, context->token2_address);
		context->current_tuple_offset = msg->parameterOffset;
		PRINTF("parse BOO__OUTPUTTOKEN, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BOO__OFFSET_AMOUNTS:
		PRINTF("parse BOO__OFFSET_AMOUNTS\n");
		break;
	case BOO__OFFSET_ORDERS:
		PRINTF("parse BOO__OFFSET_ORDERS\n");
		break;
	case BOO__FROM_RESERVE:
		PRINTF("parse BOO__FROM_RESERVE\n");
		// Get from_reserve, but we don't use it for now.
		if (U4BE(msg->parameter, PARAMETER_LENGTH - 4))
			context->booleans |= IS_FROM_RESERVE;
		break;
	case BOO__LEN_AMOUNTS:
		PRINTF("parse BOO__LEN_AMOUNTS\n");
		context->current_length_lvl1 = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("with current_length_lvl1 = %d\n", context->current_length_lvl1);
		break;
	case BOO__AMOUNT:
		PRINTF("parse BOO__AMOUNT, index: %d\n", context->current_length_lvl1);
		// copy last amount, matching b2c
		if (context->current_length_lvl1 == 1)
		{
			copy_parameter(context->token1_amount, msg->parameter, sizeof(context->token1_amount));
			PRINTF("copie token1 amount: %.*H\n", PARAMETER_LENGTH, context->token1_amount);
		}
		context->current_length_lvl1--;
		if (context->current_length_lvl1)
			return;
		break;
	case BOO__LEN_ORDERS:
		PRINTF("parse BOO__LEN_ORDERS\n");
		// context->current_length_lvl1 = U4BE(msg->parameter, PARAMETER_LENGTH - 4); // risky length overwrite
		context->offset_array_index = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->number_of_tokens = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("number_of_tokens: %d\n", context->number_of_tokens);
		// PRINTF("current_length_lvl1: %d\n", context->current_length_lvl1);
		// test
		context->current_tuple_offset = msg->parameterOffset + PARAMETER_LENGTH;
		PRINTF("parse BOO__LEN_ORDERS, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BOO__OFFSET_ARRAY_ORDERS:
		PRINTF("parse BOO__OFFSET_ARRAY_ORDERS, index: %d\n", context->offset_array_index);
		context->offset_array_index--;
		// copy last order, matching b2c
		if (context->offset_array_index == 0)
		{
			context->offsets_lvl1 =
					U4BE(msg->parameter, PARAMETER_LENGTH - 4) + context->current_tuple_offset;
			PRINTF("offsets_lvl1: %d\n",
						 context->offsets_lvl1);
			PRINTF("parse BOO__OFFSET_ARRAY_ORDERS LAST\n");
			// Switch to order's parsing
			context->on_struct = (on_struct)S_ORDER;
			context->next_param = (order)ORDER__OPERATOR;
		}
		return;
	default:
		PRINTF("Param not supported: %d\n", context->next_param);
		msg->result = ETH_PLUGIN_RESULT_ERROR;
		break;
	}
	context->next_param++;
}

/**
 * parse batched_input_orders struct
 */
void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("PARSING BIO step; %d\n", context->next_param);
	switch ((batch_input_orders)context->next_param)
	{
	case BIO__INPUTTOKEN:
		PRINTF("parse BIO__INPUTTOKEN\n");
		copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
		PRINTF("Copied inputToken to token1_address: %.*H\n", ADDRESS_LENGTH, context->token1_address);
		// Set current_tuple_offset for parsing purposes
		context->current_tuple_offset = msg->parameterOffset;
		PRINTF("parse BIO__INPUTTOKEN, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BIO__AMOUNT:
		PRINTF("parse BIO__AMOUNT\n");
		copy_parameter(context->token1_amount, msg->parameter, sizeof(context->token1_amount));
		PRINTF("get token1_amount: %d\n");
		break;
	case BIO__OFFSET_ORDERS:
		PRINTF("parse BIO__OFFSET_ORDERS\n");
		break;
	case BIO__FROM_RESERVE:
		PRINTF("parse BIO__FROM_RESERVE\n");
		// Get from_reserve, but we don't use it for now.
		if (U4BE(msg->parameter, PARAMETER_LENGTH - 4))
			context->booleans |= IS_FROM_RESERVE;
		break;
	case BIO__LEN_ORDERS:
		PRINTF("parse BIO__LEN_ORDERS\n");
		context->number_of_tokens = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->offset_array_index = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->current_tuple_offset = msg->parameterOffset + PARAMETER_LENGTH;
		PRINTF("parse BIO__LEN_ORDERS, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BIO__OFFSET_ARRAY_ORDERS:
		PRINTF("parse BIO__OFFSET_ARRAY_ORDERS\n");
		context->offset_array_index--;
		// is on last order's offset
		if (context->offset_array_index == 0)
		{
			PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
			context->offsets_lvl1 =
					U4BE(msg->parameter, PARAMETER_LENGTH - 4) + context->current_tuple_offset;
			PRINTF("offsets_lvl1: %d\n",
						 context->offsets_lvl1);
			context->on_struct = (on_struct)S_ORDER;
			context->next_param = (order)ORDER__OPERATOR;
		}
		return;
	default:
		PRINTF("Param not supported: %d\n", context->next_param);
		msg->result = ETH_PLUGIN_RESULT_ERROR;
		break;
	}
	context->next_param++;
}
