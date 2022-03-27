#include "nested_plugin.h"

void parse_order(ethPluginProvideParameter_t *msg, context_t *context)
{
	if (context->offsets_lvl1[0] == msg->parameterOffset)
	{
		PRINTF("PENZO START LAST ORDER\n");
		context->next_param = (order)ORDER__OPERATOR;
	}
	PRINTF("PARSING ORDER\n");
	switch ((order)context->next_param)
	{
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
		PRINTF("parse ORDER__CALLDATA start\n");
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
		copy_address(context->token1_address, msg->parameter, ADDRESS_LENGTH);
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
		break;
	case BOO__LEN_ORDERS:
		PRINTF("parse BOO__LEN_ORDERS\n");
		context->current_length = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		context->length_offset_array = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
		PRINTF("current_length: %d\n", context->current_length);
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
			context->next_param = (batch_input_orders)ORDER__OPERATOR;
		}
		return;
		break;
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
