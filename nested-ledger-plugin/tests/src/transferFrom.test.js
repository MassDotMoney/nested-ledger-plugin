import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, nano_models, SPECULOS_ADDRESS, txFromEtherscan, resolutionConfig, loadConfig } from './test.fixture';
import ledgerService from "@ledgerhq/hw-app-eth/lib/services/ledger"
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";

nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Transfer From', zemu(model, async (sim, eth) => {
    let unsignedTx = genericTx;

    unsignedTx.to = contractAddr;
    // https://snowtrace.io/tx/0xed4480a4ea78338c365d16a3218c051dec565bda7cab6cd4d47da70005fb9f89
    unsignedTx.data = "0x23b872dd000000000000000000000000762a4b0179f7872c94d69aab0e02702f1db3418c0000000000000000000000008d9f950c23b73edf79ce52f74c6fb589cd2cbd900000000000000000000000000000000000000000000000000000000000000001";
    unsignedTx.value = parseEther("1");

    // Create serializedTx and remove the "0x" prefix
    const serializedTx = ethers.utils.serializeTransaction(unsignedTx).slice(2);

    const resolution = await ledgerService.resolveTransaction(
      serializedTx,
      loadConfig,
      resolutionConfig
    );

    const tx = eth.signTransaction(
      "44'/60'/0'/0",
      serializedTx,
      resolution
    );

    const right_clicks = model.letter === 'S' ? 5 : 3;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_transferFrom', [right_clicks, 0]);

    await tx;
  }));
});