import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "FeeSplitter";
const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";
const testNetwork = "polygon";

const testLabel = "Release 3 tokens MATIC USDC USDT"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0xb543d05c24a54203b7b712629d4abb8276d4727f581a8b395f8bbedb3c5a40b1
const inputData = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000030000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa841740000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c2132d05d31c914a87c6611c10748aeb04b58e8f";

// [NanoS steps, NanoX steps]
const steps = [5, 5]

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
nano_models.forEach((model) =>
	processTest(model, steps, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork)
);