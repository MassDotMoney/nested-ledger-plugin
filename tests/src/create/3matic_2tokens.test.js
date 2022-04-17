import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "NestedFactory";
const contractAddr = "0xfd896db057f260adce7fd1fd48c6623e023406cd";
const testNetwork = "polygon";

const testLabel = "create 3matic 2 tokens"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0x14297c32a09294e73649d27fb986ad4f433bbd3117ba48f5c2a97f68927dc627
const inputData = "0xa378534b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000029a2241af62c0000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000007405a65726f45780000000000000000000000000000000000000000000000000000000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000006800000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000005e8415565b00000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f000000000000000000000000000000000000000000000000149bc7a1d37480000000000000000000000000000000000000000000000000000000000000203c9f00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002a0000000000000000000000000000000000000000000000000149bc7a1d374800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000012556e6973776170563300000000000000000000000000000000000000000000000000000000000000149bc7a1d37480000000000000000000000000000000000000000000000000000000000000203c9f000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000e592427a0aece92de3edee1f18e0157c058615640000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002b0d500b1d8e8ef31e21c99d1db9a6444d3adf12700001f4c2132d05d31c914a87c6611c10748aeb04b58e8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000010000000000000000000000000000000000000110000000000000000000000000000000000000000000000eda321f217623366180000000000000000000000000000000000000000000000005a65726f457800000000000000000000000000000000000000000000000000000000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000006800000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000005e8415565b00000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619000000000000000000000000000000000000000000000000149bc7a1d37480000000000000000000000000000000000000000000000000000002ad6f935b1f7700000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000002a0000000000000000000000000000000000000000000000000149bc7a1d3748000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000025761756c745377617000000000000000000000000000000000000000000000000000000000000000149bc7a1d37480000000000000000000000000000000000000000000000000000002ad6f935b1f77000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000003a1d87f206d12415f5b0a33e786967680aab4f6d000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000007ceb23fd6bc0add59e62ac25578270cff1b9f619000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000010000000000000000000000000000000000000110000000000000000000000000000000000000000000000ca6999aaf962336618000000000000000000000000000000000000000000000000";

// [NanoS steps, NanoX steps]
const steps = [6, 6]

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
nano_models.forEach((model) =>
	processTest(model, steps, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork)
);