#include "nested_plugin.h"

static void print_booleans(context_t *context)
{
    PRINTF("IS_COPY %d\n", context->screen_array & IS_COPY);
    PRINTF("TOKEN1_FOUND %d\n", context->screen_array & TOKEN1_FOUND);
    PRINTF("TOKEN2_FOUND %d\n", context->screen_array & TOKEN2_FOUND);
    PRINTF("IS_FROM_RESERVE %d\n", context->screen_array & IS_FROM_RESERVE);
    PRINTF("BOOL5 %d\n", context->screen_array & BOOL5);
    PRINTF("BOOL6 %d\n", context->screen_array & BOOL6);
    PRINTF("BOOL7 %d\n", context->screen_array & BOOL7);
    PRINTF("BOOL8 %d\n", context->screen_array & BOOL8);
}

static uint8_t count_screens(uint8_t screen_array)
{
    uint8_t total = 0;
    uint8_t scout = 1;
    for (uint8_t i = 0; i < 8; i++)
    {
        if (scout & screen_array)
            total++;
        scout <<= 1;
    }
    return total;
}

//static void set_screens(context_t *context)
//{
//    context->screen_array |= FIRST_SCREEN_UI;
//    switch (context->selectorIndex)
//    {
//    case CREATE:
//    case DESTROY:
//    case RELEASE_TOKENS:
//        if (memcmp(context->token2_address, NULL_ADDRESS, ADDRESS_LENGTH))
//            context->screen_array |= SCREEN_2_UI;
//        break;
//    default:
//        PRINTF("set_screens ERROR\n");
//    }
//}

void handle_finalize(void *parameters)
{
    ethPluginFinalize_t *msg = (ethPluginFinalize_t *)parameters;
    context_t *context = (context_t *)msg->pluginContext;

    context->token1_decimals = DEFAULT_DECIMAL;
    context->screen_array |= FIRST_SCREEN_UI;

    switch (context->selectorIndex)
    {
    case CREATE:
    case DESTROY:
        context->screen_array |= SCREEN_2_UI;
        break;
    case RELEASE_TOKENS:
        if (context->number_of_tokens > 1)
            context->screen_array |= SCREEN_2_UI;
        break;
    }

    // set the first screen to display.
    context->plugin_screen_index = FIRST_SCREEN_UI;

    //// set `tokenLookup1` (and maybe `tokenLookup2`) to point to
    //// token addresses you will info for (such as decimals, ticker...).
    if (memcmp(context->token1_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup1 = context->token1_address;
    if (memcmp(context->token2_address, NULL_ADDRESS, ADDRESS_LENGTH))
        msg->tokenLookup2 = context->token2_address;

    print_booleans(context);

    // msg->pluginSharedRO->txContent->chainID;
    // uint8_t test[INT256_LENGTH];
    char test[12] = {0};
    txInt256_t chainID = msg->pluginSharedRO->txContent->chainID;
    // uint256_to_decimal(chainID.value, chainID.length, test, INT256_LENGTH);
    uint256_to_decimal(chainID.value, chainID.length, test, 12);
    PRINTF("CHAINID: %d\n", test);
    PRINTF("with len: %d\n", chainID.length);

    PRINTF("Bytes: \033[0;31m %.*H \033[0m \n",
           INT256_LENGTH,
           msg->pluginSharedRO->txContent->chainID.value);

    msg->uiType = ETH_UI_TYPE_GENERIC;
    msg->numScreens = count_screens(context->screen_array);
    msg->result = ETH_PLUGIN_RESULT_OK;
}
