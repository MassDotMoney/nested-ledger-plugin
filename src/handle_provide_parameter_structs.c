#include "nested_plugin.h"

/**
 * @brief Get the ui selector added by Nested front-end
 *
 * @return parsed byte
 */
static uint8_t get_ui_selector(const uint8_t *parameter)
{
	uint8_t i = 0;
	while (parameter[i] == 0 && i < PARAMETER_LENGTH)
		i++;
	return parameter[i];
}

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
	if (context->offsets_lvl1[0] == msg->parameterOffset)
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
		PRINTF("number of tokens ? %d\n", context->number_of_tokens);
		if (context->number_of_tokens == 1 && context->selectorIndex == PROCESS_OUTPUT_ORDERS)
		{
			PRINTF("copie token1 address\n");
			copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
		}
		break;
	case ORDER__OFFSET_CALLDATA:
		PRINTF("parse ORDER__OFFSET_CALLDATA\n");
		copy_offset(msg, context);
		break;
	case ORDER__LEN_CALLDATA:
		PRINTF("parse ORDER__LEN_CALLDATA\n");
		// is on last order ???
		if (msg->parameterOffset > context->offsets_lvl1[0])
		{
			// get last_calldata_offset to parse last Tx's byte
			context->last_calldata_offset = msg->parameterOffset + PARAMETER_LENGTH + U4BE(msg->parameter, PARAMETER_LENGTH - 4);
			PRINTF("LAST ORDER offset: %d\n", context->last_calldata_offset);
		}
		break;
	case ORDER__CALLDATA:
		PRINTF("parse ORDER__CALLDATA start\n");
		break;
	default:
		break;
	}
	context->next_param++;
}

void parse_batched_output_orders(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("PARSING BOO step; %d\n", context->next_param);
	switch ((batch_output_orders)context->next_param)
	{
	case BOO__OUTPUTTOKEN:
		PRINTF("parse BOO__OUTPUTTOKEN\n");
		copy_address(context->token2_address, msg->parameter, ADDRESS_LENGTH);
		context->current_tuple_offset = msg->parameterOffset;
		PRINTF("parse BOO__OUTPUTTOKEN, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BOO__OFFSET_AMOUNTS:
		PRINTF("parse BOO__OFFSET_AMOUNTS\n");
		break;
	case BOO__OFFSET_ORDERS:
		PRINTF("parse BOO__OFFSET_ORDERS\n");
		copy_offset(msg, context);
		break;
	case BOO__FROM_RESERVE:
		PRINTF("parse BOO__FROM_RESERVE\n");
		break;
	case BOO__LEN_AMOUNTS:
		PRINTF("parse BOO__LEN_AMOUNTS\n");
		context->current_length_lvl1 = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("with current_length_lvl1 = %d\n", context->current_length_lvl1);
		PRINTF("with current_length = %d\n", context->current_length);
		break;
	case BOO__AMOUNT:
		PRINTF("parse BOO__AMOUNT\n");
		if (context->number_of_tokens == 1)
		{
			PRINTF("copie token1 amount\n");
			copy_parameter(context->token1_amount, msg->parameter, sizeof(context->token1_amount));
		}
		context->current_length_lvl1--;
		if (context->current_length_lvl1)
			return;

		break;
	case BOO__LEN_ORDERS:
		PRINTF("parse BOO__LEN_ORDERS\n");
		context->current_length_lvl1 = U4BE(msg->parameter, PARAMETER_LENGTH - 4); // risky length overwrite
		context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("current_length_lvl1: %d\n", context->current_length_lvl1);
		// test
		context->current_tuple_offset = msg->parameterOffset + PARAMETER_LENGTH;
		PRINTF("parse BOO__LEN_ORDERS, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BOO__OFFSET_ARRAY_ORDERS:
		context->length_offset_array--;
		PRINTF("parse BOO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
		if (context->length_offset_array < 2)
		{
			context->offsets_lvl1[context->length_offset_array] =
				U4BE(msg->parameter, PARAMETER_LENGTH - 4) + context->current_tuple_offset;
			PRINTF("offsets_lvl1[%d]: %d\n",
				   context->length_offset_array,
				   context->offsets_lvl1[context->length_offset_array]);
		}
		if (context->length_offset_array == 0)
		{
			PRINTF("parse BOO__OFFSET_ARRAY_ORDERS LAST\n");
			context->on_struct = (on_struct)S_ORDER;
			context->next_param = (order)ORDER__OPERATOR;
		}
		return;
	default:
		break;
	}
	context->next_param++;
}

void parse_batched_input_orders(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("PARSING BIO step; %d\n", context->next_param);
	switch ((batch_input_orders)context->next_param)
	{
	case BIO__INPUTTOKEN:
		PRINTF("parse BIO__INPUTTOKEN\n");
		copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
		context->current_tuple_offset = msg->parameterOffset;
		PRINTF("parse BIO__INPUTTOKEN, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BIO__AMOUNT:
		PRINTF("parse BIO__AMOUNT\n");
		copy_parameter(context->token1_amount, msg->parameter, sizeof(context->token1_amount));
		break;
	case BIO__OFFSET_ORDERS:
		PRINTF("parse BIO__OFFSET_ORDERS\n");
		copy_offset(msg, context);
		break;
	case BIO__FROM_RESERVE:
		PRINTF("parse BIO__FROM_RESERVE\n");
		if (U4BE(msg->parameter, PARAMETER_LENGTH - 4))
			context->booleans |= IS_FROM_RESERVE;
		break;
	case BIO__LEN_ORDERS:
		PRINTF("parse BIO__LEN_ORDERS\n");
		context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->number_of_tokens = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("current_length: %d\n", context->current_length);
		// test
		context->current_tuple_offset = msg->parameterOffset + PARAMETER_LENGTH;
		PRINTF("parse BIO__LEN_ORDERS, NEW TUPLE_OFFSET: %d\n", context->current_tuple_offset);
		break;
	case BIO__OFFSET_ARRAY_ORDERS:
		context->length_offset_array--;
		PRINTF("parse BIO__OFFSET_ARRAY_ORDERS, index: %d\n", context->length_offset_array);
		if (context->length_offset_array < 2)
		{
			context->offsets_lvl1[context->length_offset_array] =
				U4BE(msg->parameter, PARAMETER_LENGTH - 4) + context->current_tuple_offset;
			PRINTF("offsets_lvl1[%d]: %d\n",
				   context->length_offset_array,
				   context->offsets_lvl1[context->length_offset_array]);
		}
		if (context->length_offset_array == 0)
		{
			PRINTF("parse BIO__OFFSET_ARRAY_ORDERS LAST\n");
			context->on_struct = (on_struct)S_ORDER;
			context->next_param = (batch_input_orders)ORDER__OPERATOR;
		}
		return;
		break;
	default:
		break;
	}
	context->next_param++;
}
