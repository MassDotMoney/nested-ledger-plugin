import Zemu, { DEFAULT_START_OPTIONS, DeviceModel } from '@zondax/zemu';
import Eth from '@ledgerhq/hw-app-eth';
import { generate_plugin_config } from './generate_plugin_config';
import { parseEther, parseUnits, RLP } from "ethers/lib/utils";
import { ethers } from "ethers";
import ledgerService from "@ledgerhq/hw-app-eth/lib/services/ledger"

const transactionUploadDelay = 900000;

const sim_options_nano = {
  ...DEFAULT_START_OPTIONS,
  logging: true,
  X11: true,
  startDelay: 5000,
  startText: 'is ready'
};

const Resolve = require('path').resolve;

const NANOS_ETH_PATH = Resolve('elfs/ethereum_nanos.elf');
const NANOX_ETH_PATH = Resolve('elfs/ethereum_nanox.elf');
const NANOSP_ETH_PATH = Resolve('elfs/ethereum_nanosp.elf');

const NANOS_PLUGIN_PATH = Resolve('elfs/plugin_nanos.elf');
const NANOX_PLUGIN_PATH = Resolve('elfs/plugin_nanox.elf');
const NANOSP_PLUGIN_PATH = Resolve('elfs/plugin_nanosp.elf');

const SPECULOS_ADDRESS = '0xFE984369CE3919AA7BB4F431082D027B4F8ED70C';
const RANDOM_ADDRESS = '0xaaaabbbbccccddddeeeeffffgggghhhhiiiijjjj'

const NFT_EXPLORER_BASE_URL = "https://nft.api.live.ledger.com/v1/ethereum"
const PLUGIN_BASE_URL = "https://cdn.live.ledger.com"

const nano_models = [
  { name: 'nanos', letter: 'S', path: NANOS_PLUGIN_PATH, eth_path: NANOS_ETH_PATH },
  { name: 'nanox', letter: 'X', path: NANOX_PLUGIN_PATH, eth_path: NANOX_ETH_PATH },
  { name: 'nanosp', letter: 'SP', path: NANOSP_PLUGIN_PATH, eth_path: NANOSP_ETH_PATH }
];

const resolutionConfig = {
  externalPlugins: true,
  nft: false,
  erc20: false
};

let genericTx = {
  nonce: Number(0),
  gasLimit: Number(21000),
  gasPrice: parseUnits('1', 'gwei'),
  value: parseEther('1'),
  chainId: 1,
  to: RANDOM_ADDRESS,
  data: null,
};

const TIMEOUT = 1000000;

function zemu(device, testNetwork, func) {
  return async () => {
    jest.setTimeout(TIMEOUT);
    let elf_path;
    let lib_elf;
    elf_path = device.eth_path;
    lib_elf = { 'Nested': device.path };

    const sim = new Zemu(elf_path, lib_elf);

    try {
      await sim.start({ ...sim_options_nano, model: device.name });
      const transport = sim.getTransport();
      const eth = new Eth(transport);
      eth.setLoadConfig({
        // baseURL: null,
        nftExplorerBaseURL: NFT_EXPLORER_BASE_URL,
        pluginBaseURL: PLUGIN_BASE_URL,
        extraPlugins: generate_plugin_config(testNetwork),
      });
      await func(sim, eth);
    } finally {
      await sim.close();
    }
  };
}

/**
 * Process the trasaction through the full test process in interaction with the simulator
 * @param {Eth} eth Device to test (nanos, nanox)
 * @param {function} sim Zemu simulator
 * @param {int} steps Number of steps to push right button
 * @param {string} label directory against which the test snapshots must be checked.
 * @param {string} testNetwork network name
 * @param {string} unsignedTx unsignedTx to serialized
 */
async function processTransaction(eth, sim, steps, label, testNetwork, unsignedTx) {
  const loadConfig = {
    nftExplorerBaseURL: NFT_EXPLORER_BASE_URL,
    pluginBaseURL: PLUGIN_BASE_URL,
    extraPlugins: generate_plugin_config(testNetwork),
  };

  const serializedTx = ethers.utils.serializeTransaction(unsignedTx).slice(2);

  const resolution = await ledgerService.resolveTransaction(
    serializedTx,
    loadConfig,
    resolutionConfig
  );

  let tx = eth.signTransaction("44'/60'/0'/0/0", serializedTx, resolution);

  await sim.waitUntilScreenIsNot(
    sim.getMainMenuSnapshot(),
    transactionUploadDelay
  );
  await sim.navigateAndCompareSnapshots(".", label, [steps, 0]);

  await tx;
}

/**
 * Function to execute test with the simulator
 * @param {Object} device Device including its name, its label, and the number of steps to process the use case
 * @param {number} step Number of screens for this Tx
 * @param {string} contractName Name of the contract
 * @param {string} testLabel Name of the test case
 * @param {string} testDirSuffix Name of the folder suffix for snapshot comparison
 * @param {string} unsignedTx unsignedTx to serialized
 * @param {string} testNetwork network name
 */
function processTest(device, step, contractName, testLabel, testDirSuffix, unsignedTx, testNetwork = "ethereum") {
  test(
    "[" + device.letter + "]" + "[" + contractName + "] - " + testLabel,
    zemu(device, testNetwork, async (sim, eth) => {
      await processTransaction(
        eth,
        sim,
        step,
        testNetwork + "_" + device.name + "_" + testDirSuffix,
        testNetwork,
        unsignedTx
      );
    }),
    130000
  );
}

const supportedNetwork = {
  'polygon': 137,
  'ethereum': 1,
  'bsc': 56,
  'avalanche': 43114,
  // 'celo': 42220,
  'arbitrum': 42161,
  'optimism': 10,
  // 'fantom': 250,
}

function populateTransaction(contractAddr, inputData, networkName, value = "0.1") {
  // Get the generic transaction template
  let unsignedTx = genericTx;
  // Adapt to the appropriate network
  unsignedTx.chainId = supportedNetwork[networkName]
  // Modify `to` to make it interact with the contract
  unsignedTx.to = contractAddr;
  // Modify the attached data
  unsignedTx.data = inputData;
  // Modify the number of ETH sent
  unsignedTx.value = parseEther(value);
  return unsignedTx;
}

module.exports = {
  zemu,
  genericTx,
  nano_models,
  SPECULOS_ADDRESS,
  RANDOM_ADDRESS,
  processTest,
  populateTransaction,
}
