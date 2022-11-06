import { nano_models, populateTransaction, processTest } from "../test.fixture";

const contractName = "NestedFactory";
const contractAddr = "0xfd896db057f260adce7fd1fd48c6623e023406cd";
const testNetwork = "polygon";

const testLabel = "new buy_stable_portfolio"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, "_");

// https://polygonscan.com/tx/0x6bceead478c83a931188d027cc6f4fbe46b622c350eb421c2eb9bfe7bc05955a
const inputData =
  "0x90e1aa69000000000000000000000000000000000000000000000000000000000000b0c90000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000000000000000000000000000000000000000001d9d00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000205a65726f457800000000000000000000000000000000000000000000000000000000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000006800000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000005e8415565b00000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a0630000000000000000000000000000000000000000000000000000000000001d86000000000000000000000000000000000000000000000000001a01de54af79a800000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000001d8600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000002417065537761700000000000000000000000000000000000000000000000000000000000000000000000000000001d86000000000000000000000000000000000000000000000000001a01de54af79a8000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000c0788a3ad43d79aa53b09c2eacc313a787d1d607000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000008f3cf7ad23cd3cadbd9735aff958023239c6a063000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000020000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000010000000000000000000000000000000000000110000000000000000000000000000000000000000000000abe253945b634979fc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006";

const models = [
  {
    name: "nanos",
    steps: 6,
  },
  // {
  // 	name: 'nanox',
  // 	steps: 0
  // },
];

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
models.forEach((model) => {
  const nano_model = nano_models.find((nano_model) =>
    nano_model.name === model.name
  );
  processTest(
    nano_model,
    model.steps,
    contractName,
    testLabel,
    testDirSuffix,
    unsignedTx,
    testNetwork,
  );
});
