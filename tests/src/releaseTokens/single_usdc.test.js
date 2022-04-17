import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "FeeSplitter";
const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";
const testNetwork = "polygon";

const testLabel = "Release Single USDC"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0xb543d05c24a54203b7b712629d4abb8276d4727f581a8b395f8bbedb3c5a40b1
const inputData = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002791bca1f2de4661ed88a30c99a7a9449aa84174";

// [NanoS steps, NanoX steps]
const steps = [5, 3]

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
nano_models.forEach((model) =>
	processTest(model, steps, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork)
);