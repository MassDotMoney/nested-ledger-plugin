import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, nano_models, resolveTxFromData, signTransaction } from './test.fixture';

const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";

// https://polygonscan.com/tx/0xb543d05c24a54203b7b712629d4abb8276d4727f581a8b395f8bbedb3c5a40b1
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release Tokens Single', zemu(model, async (sim, eth) => {
    const data = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)
    const right_clicks = model.letter === 'S' ? 5 : 3;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokensSingle', [right_clicks, 0]);

    await tx;
  }));
});

// https://polygonscan.com/tx/0xb543d05c24a54203b7b712629d4abb8276d4727f581a8b395f8bbedb3c5a40b1 // but wrong token address (2791 -> 2792)
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release Address Tokens Single', zemu(model, async (sim, eth) => {
    const data = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002792bca1f2de4661ed88a30c99a7a9449aa84174";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)
    const right_clicks = model.letter === 'S' ? 7 : 3;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokensSingle_tokenAddress', [right_clicks, 0]);

    await tx;
  }));
});

// https://polygonscan.com/tx/0x70adffc13394750fe22355acd9d3544aec2847e218451eb62bb388a97fb5b230
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release Tokens All', zemu(model, async (sim, eth) => {
    const data = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)

    const right_clicks = model.letter === 'S' ? 6 : 4;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_releaseTokensAll', [right_clicks, 0]);

    await tx;
  }));
});

// https://polygonscan.com/tx/0xf869612064cc5b75c8b3baf72e2b5668d64e51cad8cba60c550c101fd117d7ae
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release 2 tokens', zemu(model, async (sim, eth) => {
    const data = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)

    const right_clicks = model.letter === 'S' ? 6 : 4;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_release_2_tokens', [right_clicks, 0]);

    await tx;
  }));
});

// fake
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Release 3 tokens', zemu(model, async (sim, eth) => {
    const data = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)

    const right_clicks = model.letter === 'S' ? 5 : 5;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_release_3_tokens', [right_clicks, 0]);

    await tx;
  }));
});