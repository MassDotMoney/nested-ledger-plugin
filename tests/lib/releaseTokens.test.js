"use strict";

require("core-js/stable");

require("regenerator-runtime/runtime");

var _test = require("./test.fixture");

var _ledger = _interopRequireDefault(require("@ledgerhq/hw-app-eth/lib/services/ledger"));

var _ethers = require("ethers");

var _utils = require("ethers/lib/utils");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";

_test.nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] releaseTokens', (0, _test.zemu)(model, async (sim, eth) => {
    let unsignedTx = _test.genericTx;
    unsignedTx.to = contractAddr; // https://snowtrace.io/tx/0xed4480a4ea78338c365d16a3218c051dec565bda7cab6cd4d47da70005fb9f89

    unsignedTx.data = "0x6d9634b700000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7";
    unsignedTx.value = (0, _utils.parseEther)("1"); // Create serializedTx and remove the "0x" prefix

    const serializedTx = _ethers.ethers.utils.serializeTransaction(unsignedTx).slice(2);

    const resolution = await _ledger.default.resolveTransaction(serializedTx, _test.loadConfig, _test.resolutionConfig);
    const tx = eth.signTransaction("44'/60'/0'/0", serializedTx, resolution);
    const right_clicks = model.letter === 'S' ? 9 : 7; // Wait for the application to actually load and parse the transaction

    await (0, _test.waitForAppScreen)(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokens', [right_clicks, 0]);
    await tx;
  }));
});