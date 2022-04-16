# Nested Finance Ledger plugin

Ledger lightweight app for EVM compatible transaction signing for [Nested Finance](https://nested.fi/).

# Plugins:

Plugins are lightweight applications that go hand-in-hand with the Ethereum Application on a Nano S / X device.

They allow users to safely interact with smart contracts by parsing the transaction data and displaying its content in a human readable way.

It is STRONGLY recommended to follow the [plugin guide](https://developers.ledger.com/docs/dapp/nano-plugin/overview/) in order to better understand the flow and the context for plugins.

# Formatting:

The C source code is expected to be formatted with `clang-format` 11.0.0 or higher.

# Environment Setup:

Start by setting up the dev environment by following this [walkthrough](
https://developers.ledger.com/docs/dapp/nano-plugin/environment-setup/).


It is important to git pull the nanos-secure-sdk and nanox-secure-sdk to successfully build the ethereum-app and the plugin.

*Note: At this time, the sdk's need to be pulled every time you launch the docker image.*

To be able to print while debugging, you must comment the macro 
`#define PRINTF(...)` in line 126 in `/opt/*-secure-sdk/include/os.h`.

Find more info about `PRINTF` and debugging [here](https://developers.ledger.com/docs/nano-app/debug/).

**Note You must uncomment it if the plugin is ready for deployment.**

### Build the apps.

Open `build_local_test.sh` with a text editor to see which flags to pass to build the ethereum app and the plugin.

# Testing:

You should have installed the dev environment for this section.

## Testing environment setup:

Setup the testing environment with the help of this [page](https://developers.ledger.com/docs/dapp/nano-plugin/testing/).

### Testing with ZEMU:

The tests consist of "fresh" screenshots being compared to a set of expected screenshots located in `./tests/snapshots`.

To run the tests:

`cd ./tests/`

Once in the appropriate directory, simply run `yarn test` to run all tests.

OR

`yarn test -t NAME_OF_TEST` where NAME_OF_TEST is the string associated to the singular test name.

The singular test names may be found in `nested-ledger-plugin/tests/src/*/*.test.json`.

*Note: Sometimes, batched tests may fail, it is recommended to launch a singular test for the failed one, to make sure the error does not come from the ZEMU tester.*


# Plugin edit and rework:

The plugin has 3 basic components for minor edits and rework:
1. The text.h header file.
2. The screen function calls.
3. The number of screens.

## 1. The text.h header file:

This file contains all the strings to be displayed by the plugin.

The Nano devices have a top string display and a bottom one.

These strings, defined by macros and functions, are divided in three categories:
* TITLE (top)
* MSG (bottom)
* Utilitary functions (for displaying addresses, tickers, amounts, etc).

The strings are to be copied into `msg->title` and `msg->msg` from the `EthQueryContractUI_t *msg` structure.


## 2. The screen function calls:

There are two functions where the screen strings are set.

#### ID screen:
The first screen is the ID screen, set in `src/handle_query_contract_id.c`.

The title string is the plugin name.
The message strings are defined in `text.h`.

*Note: It is not included in the amount of screens of `msg->screenIndex`.*

#### UI screens:
These screens are set in `src/handle_query_contract_ui.c`. 

Each action called by the user has a respective function that sets the text.

The utilitary functions for displaying can be found in `src/text_utils.c`.

## 3. Number of screens:
There are two functions/files that can set the screen number.

In `src/handle_finalize.c` the `msg->numScreens` variable defines how many screens will be displayed (excluding the ID screen).

In `src/handle_provide_token.c` the `msg->additionScreens` variable allows to edit the previously set screen number.

*Note: the screen number may not be edited after `handle_provide_token` is called.*

## Load the plugin into a NanoS

You may also manually load the plugin into a NanoS (only) by following this [guide](https://developers.ledger.com/docs/nano-app/load/).

*Note: If you choose to load with ledgerblue, you may find an APDU for a transaction in `./apdus/transferFrom`. Use it to make sure the plugin doesn't blind-sign.*
