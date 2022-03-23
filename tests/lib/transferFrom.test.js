"use strict";

require("core-js/stable");

require("regenerator-runtime/runtime");

var _test = require("./test.fixture");

var _ledger = _interopRequireDefault(require("@ledgerhq/hw-app-eth/lib/services/ledger"));

var _ethers = require("ethers");

var _utils = require("ethers/lib/utils");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";

_test.nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Transfer From', (0, _test.zemu)(model, async (sim, eth) => {
    let unsignedTx = _test.genericTx;
    unsignedTx.to = contractAddr; // https://snowtrace.io/tx/0xed4480a4ea78338c365d16a3218c051dec565bda7cab6cd4d47da70005fb9f89

    unsignedTx.data = "0x23b872dd000000000000000000000000762a4b0179f7872c94d69aab0e02702f1db3418c0000000000000000000000008d9f950c23b73edf79ce52f74c6fb589cd2cbd900000000000000000000000000000000000000000000000000000000000000001";
    unsignedTx.value = (0, _utils.parseEther)("1"); 

    const serializedTx = _ethers.ethers.utils.serializeTransaction(unsignedTx).slice(2); // Create serializedTx and remove the "0x" prefix

    const resolution = await _ledger.default.resolveTransaction(serializedTx, _test.loadConfig, _test.resolutionConfig);
    const tx = eth.signTransaction("44'/60'/0'/0", serializedTx, resolution);
    const right_clicks = model.letter === 'S' ? 3 : 4; // Wait for the application to actually load and parse the transaction

    await (0, _test.waitForAppScreen)(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + 'transferFrom', [right_clicks, 0]);
    await tx;
  }));
});