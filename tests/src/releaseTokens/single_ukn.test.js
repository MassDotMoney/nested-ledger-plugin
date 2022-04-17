import { nano_models, processTest, populateTransaction } from "../test.fixture";

const contractName = "FeeSplitter";
const contractAddr = "0x449d088c9f184af598fe72d26742a58a11c5200f";
const testNetwork = "polygon";

const testLabel = "Release Single unknownToken"; // <= Name of the test
const testDirSuffix = testLabel.toLowerCase().replace(/\s+/g, '_');

// https://polygonscan.com/tx/0xb543d05c24a54203b7b712629d4abb8276d4727f581a8b395f8bbedb3c5a40b1
// but wrong token address (2791 -> 2792)
const inputData = "0x6d9634b7000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002792bca1f2de4661ed88a30c99a7a9449aa84174";

const models = [
	{
		name: 'nanos',
		steps: 7
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