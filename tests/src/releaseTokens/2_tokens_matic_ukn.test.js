import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "FeeSplitter";
const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";
const testNetwork = "polygon";

const testLabel = "Release 2 tokens Matic unknownToken"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0xf869612064cc5b75c8b3baf72e2b5668d64e51cad8cba60c550c101fd117d7ae
// but wrong usdc token address (2791 -> 2792)
const inputData = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf12700000000000000000000000002792bca1f2de4661ed88a30c99a7a9449aa84174";

const models = [
	{
		name: 'nanos',
		steps: 5
	},
	// {
	// 	name: 'nanox',
	// 	steps: 0
	// },
]

// populate unsignedTx from genericTx and get network chain id
const unsignedTx = populateTransaction(contractAddr, inputData, testNetwork);
// Process tests for each nano models
models.forEach((model) => {
	const nano_model = nano_models.find((nano_model) => nano_model.name === model.name)
	processTest(nano_model, model.steps, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork)
})