import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "NestedNFT";
const contractAddr = "0x0fff7f99d2b32849848e31cb48090c5268e06f65";
const testNetwork = "polygon";

const testLabel = "transferFrom"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0xd9ac5a4bf040135dd90b41e5827c5c4d559c8cab48182fad241eb41d5f98ffd0
const inputData = "0x23b872dd000000000000000000000000dd2b3f1d3a4f08622a25a3f75284fc01ad0c5cca000000000000000000000000e22bc381f60c830b50cbd1189340f26683c39f580000000000000000000000000000000000000000000000000000000000004ac8";

// [NanoS steps, NanoX steps]
const steps = [7, 5]

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
nano_models.forEach((model) =>
	processTest(model, steps, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork)
);