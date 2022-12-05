# Nested Finance Ledger plugin

Ledger lightweight app for [Nested](https://nested.fi/).

## Plugins:

Plugins are lightweight applications that go hand-in-hand with the Ethereum Application on Nano S, X and S+ devices.

They allow users to safely interact with smart contracts by parsing the transaction data and displaying its content in a human readable way.

It is STRONGLY recommended to follow the [plugin guide](https://developers.ledger.com/docs/dapp/nano-plugin/overview/) in order to better understand the flow and the context for plugins.

## Formating:

The C source code is expected to be formatted with `clang-format` 11.0.0 or higher.

# Environment Setup:

[Get Docker](https://docs.docker.com/get-docker/) and [Docker-compose](https://docs.docker.com/compose/install/).

In a terminal window:

`mkdir plugin_dev`

`cd plugin_dev`

`git clone https://github.com/LedgerHQ/app-ethereum`

`git clone https://github.com/LedgerHQ/plugin-tools`

`git clone https://github.com/NestedFi/nested-ledger-plugin/`

## Build the apps

Launch Docker.

In the same terminal:

`cd plugin-tools`

`./start.sh`

`cd ../nested-ledger-plugin/tests/`

`./build_locals_test.sh all`

If needed, replace `all` with the appropriate flags to specifically build the plugin for S, X and the ethereum app.

# Running the tests:

## Testing with ZEMU:

The tests consist of recent snapshots in `./tests/snapshot-tmp` being compared to a set of expected snapshots located in

`./tests/snapshots`.

Open another terminal window.

`cd <path>/nested-ledger-plugin/tests`.

`yarn test` to run all tests

#### OR

`yarn test -t "<name-of-test>"` to run a singular test.

The singular test names can be found in the `./tests/src/<test-folder>/*.test.js` files.

*Note: Sometimes, batched tests may fail. It is recommended to launch a singular test for the failed one to make sure the error does not come from the ZEMU tester.*

Find more information about the Zondax [ZEMU tester](https://developers.ledger.com/docs/dapp/nano-plugin/testing/).

## Testing on browser:

It is possible to send APDU's to a browser hosted Nano S emulator using [speculos](https://github.com/LedgerHQ/speculos) via Docker.

Install [ledgerblue](https://github.com/LedgerHQ/blue-loader-python/):

`pip3 install ledgerblue`

Add these aliases.

`speculos='docker run --rm -it -v <path>/plugin_dev/nested-ledger-plugin/tests/elfs:/speculos/apps -p 5000:5000 --publish 41000:41000 speculos --display headless --vnc-port 41000 --apdu-port 41000 apps/ethereum_nanos.elf -l Nested:apps/nested_nanos.elf'`

`ledgerspec='cat <path>/plugin_dev/nested-ledger-plugin/tests/apdu/"$1" | LEDGER_PROXY_ADDRESS=127.0.0.1 LEDGER_PROXY_PORT=41000 python3 -m ledgerblue.runScript --apdu'`

In a new terminal window enter:

`speculos`

Open a browser page and enter `localhost:5000` in the url field. The browser page should be emulating a Nano S.

In another terminal window type:

`ledgerspec transferFrom`

The emulating page should display a Nested NFT transfer transaction.

More information on the [speculos doc page](https://speculos.ledger.com/).

# Plugin modifications:

## Basic modifications:

The plugin has 3 basic components for modifications:

1. Number of screens.
2. Screen function calls.
3. String macros and functions.

### 1. Number of screens:
There are two variables that can set the screen number.

In `./src/handle_finalize.c` the `msg->numScreens` variable defines how many screens will be displayed.

In `./src/handle_provide_token.c` the `msg->additionalScreens` variable increases the previously set screen number.

Both are summed into `msg->screenIndex` which is used to scroll through screens.

### 2. Screen function calls:

There are two functions where the screen strings are set.

#### ID screen:
The first screen is the ID screen, set in `./src/handle_query_contract_id.c`.

*Note: It is not included in the amount of screens of `msg->screenIndex`.*

#### UI screens:
 
These screens are set in `./src/handle_query_contract_ui.c`. 

Edit the `switch(msg->screenIndex)` cases of `handle_<name-of-action>_ui()` functions if needed.

### 3. String macros and functions:

The strings displayed by the plugin are set by macros and functions.
 
 #### Macros:

* `TITLE_<NAME_OF_ACTION>_SCREEN_#_UI` (top)
* `MSG_<NAME_OF_ACTION>_SCREEN_#_UI` (bottom)

Edit these in `./src/text.h` to modify the strings displayed to the user.

 #### Functions:

These utilitary functions are used for displaying addresses, tickers, amounts, etc.

They are located in in `./src/text_utils.c`.

## Advanced modifications:

Follow this [guide](https://developers.ledger.com/docs/dapp/nano-plugin/selectors/) to further modify the plugin.

# Deployment

Visit this [page](https://developers.ledger.com/docs/nano-app/requirements-intro/) to make sure the plugin meets the standards and you have completed all the steps necessary for deployment.
