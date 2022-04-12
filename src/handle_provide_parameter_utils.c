#include "nested_plugin.h"

/**
 * copy target offset into context->next_offset using context->current_tuple_offset.
 * @brief copy target offset into context->next_offset.
 */
void copy_offset(ethPluginProvideParameter_t *msg, context_t *context)
{
	PRINTF("msg->parameterOffset: %d\n", msg->parameterOffset);
	uint32_t test = U4BE(msg->parameter, PARAMETER_LENGTH - 4);
	PRINTF("U4BE msg->parameter: %d\n", test);
	context->next_offset = test + context->current_tuple_offset;
	PRINTF("copied offset: %d\n", context->next_offset);
}