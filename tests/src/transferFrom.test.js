import "core-js/stable";
import "regenerator-runtime/runtime";
import { waitForAppScreen, zemu, nano_models, resolveTxFromData, signTransaction } from './test.fixture';

const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";

nano_models.forEach(function (model) {
  test('[Nano ' + model.letter + '] Transfer From', zemu(model, async (sim, eth) => {
    const data = "0x23b872dd000000000000000000000000762a4b0179f7872c94d69aab0e02702f1db3418c0000000000000000000000008d9f950c23b73edf79ce52f74c6fb589cd2cbd900000000000000000000000000000000000000000000000000000000000000001";
    const [resolution, serializedTx] = await resolveTxFromData(data, contractAddr);
    const tx = signTransaction(serializedTx, resolution, eth.signTransaction)

    const right_clicks = model.letter === 'S' ? 7 : 5;

    // Wait for the application to actually load and parse the transaction
    await waitForAppScreen(sim);
    await sim.navigateAndCompareSnapshots('.', model.name + '_transferFrom', [right_clicks, 0]);
    await tx;
  }));
});