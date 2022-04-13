import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, nano_models, resolveTxFromData, signTransaction } from './test.fixture';

const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";

// https://polygonscan.com/tx/0xd9ac5a4bf040135dd90b41e5827c5c4d559c8cab48182fad241eb41d5f98ffd0
nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Send transferFrom', zemu(model, async (sim, eth) => {
    const data = "0x23b872dd000000000000000000000000dd2b3f1d3a4f08622a25a3f75284fc01ad0c5cca000000000000000000000000e22bc381f60c830b50cbd1189340f26683c39f580000000000000000000000000000000000000000000000000000000000004ac8";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)

    const right_clicks = model.letter === 'S' ? 7 : 5;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_send_transferFrom', [right_clicks, 0]);
    await tx;
  }));
});