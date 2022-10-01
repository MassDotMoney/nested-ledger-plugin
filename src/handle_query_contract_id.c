#include "nested_plugin.h"
#include "text.h"

// Sets the first screen to display.
void handle_query_contract_id(void *parameters) {
  ethQueryContractID_t *msg = (ethQueryContractID_t *)parameters;
  const context_t *context = (const context_t *)msg->pluginContext;
  // msg->name will be the upper sentence displayed on the screen.
  // msg->version will be the lower sentence displayed on the screen.

  // For the first screen, display the plugin name.
  strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);

  // Get selector according screen.
  switch (context->selectorIndex) {
  case CREATE:
    if (context->booleans & IS_COPY)
      strlcpy(msg->version, MSG_COPY_ID, msg->versionLength);
    else
      strlcpy(msg->version, MSG_CREATE_ID, msg->versionLength);
    break;
  case PROCESS_INPUT_ORDERS:
    if (context->ui_selector == ADD_TOKENS)
      strlcpy(msg->version, MSG_ADD_TOKEN_ID, msg->versionLength);
    else if (context->ui_selector == DEPOSIT)
      strlcpy(msg->version, MSG_DEPOSIT_ID, msg->versionLength);
    else if (context->ui_selector == SYNCHRONIZATION)
      strlcpy(msg->version, MSG_SYNCHRONIZATION_ID, msg->versionLength);
    else {
      PRINTF("ui_selector: %d not supported\n", context->selectorIndex);
      msg->result = ETH_PLUGIN_RESULT_ERROR;
      return;
    }
    break;
  case PROCESS_OUTPUT_ORDERS:
    if (context->ui_selector == SELL_TOKENS)
      strlcpy(msg->version, MSG_SELL_TOKENS_ID, msg->versionLength);
    else if (context->ui_selector == WITHDRAW)
      strlcpy(msg->version, MSG_WITHDRAW_ID, msg->versionLength);
    else if (context->ui_selector == SWAP)
      strlcpy(msg->version, MSG_SWAP_ID, msg->versionLength);
    else {
      PRINTF("ui_selector: %d not supported\n", context->selectorIndex);
      msg->result = ETH_PLUGIN_RESULT_ERROR;
      return;
    }
    break;
  case DESTROY:
    strlcpy(msg->version, MSG_DESTROY_ID, msg->versionLength);
    break;
  case RELEASE_TOKENS:
    strlcpy(msg->version, MSG_CLAIM_ID, msg->versionLength);
    break;
  case TRANSFER_FROM:
    strlcpy(msg->version, MSG_TRANSFER_FROM_ID, msg->versionLength);
    break;
  default:
    PRINTF("Selector index: %d not supported\n", context->selectorIndex);
    msg->result = ETH_PLUGIN_RESULT_ERROR;
    return;
  }
  msg->result = ETH_PLUGIN_RESULT_OK;
}