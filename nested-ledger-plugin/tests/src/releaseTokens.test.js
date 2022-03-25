import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, genericTx, nano_models, SPECULOS_ADDRESS, txFromEtherscan, resolutionConfig, loadConfig } from './test.fixture';
import ledgerService from "@ledgerhq/hw-app-eth/lib/services/ledger"
import { ethers } from "ethers";
import { parseEther, parseUnits } from "ethers/lib/utils";

const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";

nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release Tokens Single', zemu(model, async (sim, eth) => {
    let unsignedTx = genericTx;

    unsignedTx.to = contractAddr;
    // https://snowtrace.io/tx/0x8eaf5ba02d0dd6c3815aa0158e51eb1f61b27abb94c3f985508adb7b36cc14c9
    unsignedTx.data = "0x6d9634b700000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7";
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
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokensSingle', [right_clicks, 0]);

    await tx;
  }));
});

nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release Tokens All', zemu(model, async (sim, eth) => {
    let unsignedTx = genericTx;

    unsignedTx.to = contractAddr;
    // https://snowtrace.io/tx/0x8eaf5ba02d0dd6c3815aa0158e51eb1f61b27abb94c3f985508adb7b36cc14c9
    unsignedTx.data = "0x6d9634b700000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7";
    unsignedTx.value = parseEther("1");

    // Create serializedTx and remove the "0x" prefix
    const serializedTx = ethers.utils.serializeTransaction(unsignedTx).slice(2);

    const resolution = await ledgerService.resolveTransaction(
      serializedTx,
      loadConfig,
      resolutionConfig
    );

    console.log(eth);
    const tx = eth.signTransaction(
      "44'/60'/0'/0",
      serializedTx,
      resolution
    );

    const right_clicks = model.letter === 'S' ? 5 : 3;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokensAll', [right_clicks, 0]);

    await tx;
  }));
});