import { nano_models, populateTransaction, processTest } from "../test.fixture";

const contractName = "NestedFactory";
const contractAddr = "0xfd896db057f260adce7fd1fd48c6623e023406cd";
const testNetwork = "avalanche";

const testLabel = "v2 edit alloc"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, "_");

// https://snowtrace.io/tx/0x6b1113d7f3525a8ab99baa4bb0d3d610747fceab5a97431e3de2c48696d35bb2
const inputData =
  "0x90e1aa690000000000000000000000000000000000000000000000000000000000000819000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c6640000000000000000000000000000000000000000000000000000000000268724000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000005805061726173776170000000000000000000000000000000000000000000000000000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000004c0000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c70000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000042454e3f31b0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000b31f66aa3c1e785363f0875a1b74e27b85fd66c7000000000000000000000000000000000000000000000000000000000002102f0000000000000000000000000000000000000000000000000023ad8acea7ca430000000000000000000000000000000000000000000000000024c805dcf6e05b00000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006e65737465642e6669010000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000003e000000000000000000000000000000000000000000000000000000000638a6efcb5334fd58c80421597662a850cabbaad00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000053e693c6c7ffc4446c53b205cf513105bf140d7b00000000000000000000000000000000000000000000000000000000000000e491a32b69000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000000000000000000000000000000000000002102f0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000001000000000000000000004de4490c69b3a746a10b163f1e9a5674f2057d3d956f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e4000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005061726173776170000000000000000000000000000000000000000000000000000000000000000000000000d24c2ad096400b6fbcd2ad8b24e7acbc21a1da64000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000004e0000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000d24c2ad096400b6fbcd2ad8b24e7acbc21a1da640000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000044454e3f31b0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c664000000000000000000000000d24c2ad096400b6fbcd2ad8b24e7acbc21a1da6400000000000000000000000000000000000000000000000000000000002459760000000000000000000000000000000000000000000000001fea52cb9fcd066a00000000000000000000000000000000000000000000000020e7038aaa0582a800000000000000000000000000000000000000000000000000000000000001e00000000000000000000000000000000000000000000000000000000000000220000000000000000000000000000000000000000000000000000000000000036000000000000000000000000000000000000000000000000000000000000003c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006e65737465642e66690100000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000638a6efcde6299c97442459db3fa83fe4072a42800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000053e693c6c7ffc4446c53b205cf513105bf140d7b000000000000000000000000000000000000000000000000000000000000010491a32b69000000000000000000000000a7d7079b0fead91f3e65f86e8915cb59c1a4c66400000000000000000000000000000000000000000000000000000000002459760000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000004de4490c69b3a746a10b163f1e9a5674f2057d3d956f000000000000000000004de40ce543c0f81ac9aaa665ccaae5eec70861a6b559000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001040000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007";

const models = [
  {
    name: "nanox",
    steps: 5,
  },
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