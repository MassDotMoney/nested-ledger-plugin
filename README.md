# Nested Finance Ledger plugin

Ledger lightweight app for [Nested Finance](https://nested.fi/).

## Plugins:

Plugins are lightweight applications that go hand-in-hand with the Ethereum Application on Nano S / X devices.

They allow users to safely interact with smart contracts by parsing the transaction data and displaying its content in a human readable way.

It is STRONGLY recommended to follow the [plugin guide](https://developers.ledger.com/docs/dapp/nano-plugin/overview/) in order to better understand the flow and the context for plugins.

# Environment Setup:

Start by setting up the dev environment by following this [walkthrough](
https://developers.ledger.com/docs/dapp/nano-plugin/environment-setup/).


It is important to git pull the nanos-secure-sdk and nanox-secure-sdk to successfully build the ethereum-app and the plugin.

To be able to print while debugging, comment the macro 
`#define PRINTF(...)` in line 126 in `/opt/*-secure-sdk/include/os.h`.

*Note: Uncomment it when the plugin is ready for deployment.*

Find more info about `PRINTF` and debugging [here](https://developers.ledger.com/docs/nano-app/debug/#printf-macro).

## Formatting:

The C source code is expected to be formatted with `clang-format` 11.0.0 or higher.

## Build the apps

Start Docker.

Open a terminal window.

`cd /plugin_dev/plugin_tools/`

`./start.sh`

Run `./build_locals_test.sh all` or replace `all` with the appropriate flags to build the plugin and/or the ethereum app.

*Note: At this time, the docker sdk's need to be pulled every time you launch the docker image.*

# Testing environment setup:

Setup the testing environment with the help of this [page](https://developers.ledger.com/docs/dapp/nano-plugin/testing/).

The tests consist of recent snapshots in `./tests/snapshot-tmp` being compared to a set of expected snapshots located in

`./tests/snapshots`.

## Running the tests:

Open another terminal window.

`cd ./tests`

`yarn test`

To run all tests

#### OR

`yarn test -t "Name of test"` where `"Name of test"` is the string associated to the singular test name.

The singular test names can be found in `./tests/src/*/*.test.json`.

*Note: Sometimes, batched tests may fail. It is recommended to launch a singular test for the failed one to make sure the error does not come from the ZEMU tester.*


# Plugin modifications:

The plugin has 3 basic components for modifications:
1. String macros and functions.
2. Screen function calls.
3. Number of screens.

## 1. String macros and functions:

The strings displayed by the plugin are set by macros and functions:
 
 #### Macros:

* `TITLE_NAME_OF_ACTION_SCREEN_#_UI` (top)
* `MSG_NAME_OF_ACTION_SCREEN_#_UI` (bottom)

Both are found in `./src/text.h`. Edit these to modify the strings displayed to the user.

 #### Functions:

These utilitary functions are used for displaying addresses, tickers, amounts, etc.

They are located in in `./src/text_utils.c`.

## 2. Screen function calls:

There are two functions where the screen strings are set.

#### ID screen:
The first screen is the ID screen, set in `./src/handle_query_contract_id.c`.

*Note: It is not included in the amount of screens of `msg->screenIndex`.*

#### UI screens:
 
These screens are set in `./src/handle_query_contract_ui.c`. 

Each action called by the user has a respective function that sets the text.

Edit the `switch(msg->screenIndex)` cases of `handle_*_ui()` functions if needed.

## 3. Number of screens:
There are two functions that can set the screen number.

In `./src/handle_finalize.c` the `msg->numScreens` variable defines how many screens will be displayed.

In `./src/handle_provide_token.c` the `msg->additionScreens` variable increases the previously set screen number.

Both are summed into `msg->screenIndex` which is used to scroll through screens.

# WIP Load the plugin into a Nano S

It is also possible to sideload the plugin into a Nano S (only) by following this [guide](https://developers.ledger.com/docs/nano-app/load/).

*Note: APDU's are stored in `./apdus/transferFrom`. Use the file to make sure the plugin doesn't blind-sign. Remember to open the app. ;)*
