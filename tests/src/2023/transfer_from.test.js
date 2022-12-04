import { nano_models, populateTransaction, processTest } from "../test.fixture";

const contractName = "NestedFactory";
const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";
const testNetwork = "avalanche";

const testLabel = "2023 transfer from"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, "_");

// https://snowtrace.io/tx/0x4e2cbba825a25937b3016ecb2e8d96036b2c587f3689cf96470fecda65c190cc
const inputData =
  "0x23b872dd000000000000000000000000762a4b0179f7872c94d69aab0e02702f1db3418c000000000000000000000000762a4b0179f7872c94d69aab0e02702f1db3418c00000000000000000000000000000000000000000000000000000000000008190000000000000000000000000000000c";

const models = [
  {
    name: "nanos",
    steps: 7,
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
