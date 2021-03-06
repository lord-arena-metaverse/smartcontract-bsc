import path from "path";
import fs from "fs";
import { HardhatUserConfig } from "hardhat/config";
// @ts-ignore
import { accounts } from "./test-wallets.js";
import { eEthereumNetwork } from "./helpers/types";
import { BUIDLEREVM_CHAINID, COVERAGE_CHAINID } from "./helpers/buidler-constants";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-gas-reporter";
import "hardhat-typechain";
import "solidity-coverage";

require("dotenv").config();

const SKIP_LOAD = process.env.SKIP_LOAD === "true";
const DEFAULT_BLOCK_GAS_LIMIT = 12450000;
const DEFAULT_GAS_PRICE = 100 * 1000 * 1000 * 1000; // 75 gwei
const HARDFORK = "istanbul";
const INFURA_KEY = process.env.INFURA_KEY || "";
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY || "";
const MNEMONIC_PATH = "m/44'/60'/0'/0";
const MNEMONIC = process.env.MNEMONIC || "";
// const PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const PRIVATE_PROD_KEY = process.env.PRIVATE_PROD_KEY || "";
const PROXY_PRIVATE_KEY = process.env.PROXY_PRIVATE_KEY || "";

// Prevent to load scripts before compilation and typechain
if (!SKIP_LOAD) {
  ["misc", "dev"].forEach((folder) => {
    const tasksPath = path.join(__dirname, "tasks", folder);
    fs.readdirSync(tasksPath)
      .filter((pth) => pth.includes(".ts"))
      .forEach((task) => {
        require(`${tasksPath}/${task}`);
      });
  });
}

require(`${path.join(__dirname, "tasks/misc")}/set-DRE.ts`);

const getCommonNetworkConfig = (networkName: eEthereumNetwork, networkId: number) => {
  return {
    url: `https://${networkName}.infura.io/v3/${INFURA_KEY}`,
    hardfork: HARDFORK,
    blockGasLimit: DEFAULT_BLOCK_GAS_LIMIT,
    gasMultiplier: DEFAULT_GAS_PRICE,
    chainId: networkId,
    accounts: {
      mnemonic: MNEMONIC,
      path: MNEMONIC_PATH,
      initialIndex: 0,
      count: 20,
    },
  };
};

const buidlerConfig: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
      {
        version: "0.7.5",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
      {
        version: "0.6.10",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: { enabled: true, runs: 200 },
          evmVersion: "istanbul",
        },
      },
    ],
  },
  typechain: {
    outDir: "types",
    target: "ethers-v5",
  },
  etherscan: {
    apiKey: ETHERSCAN_KEY,
  },
  mocha: {
    timeout: 0,
  },
  networks: {
    kovan: getCommonNetworkConfig(eEthereumNetwork.kovan, 42),
    ropsten: getCommonNetworkConfig(eEthereumNetwork.ropsten, 3),
    main: getCommonNetworkConfig(eEthereumNetwork.main, 1),
    bbtest: {
      url: "https://data-seed-prebsc-1-s2.binance.org:8545/",
      // url: 'https://bsc-dataseed.binance.org/',
      chainId: 97,
      // chainId: 56,
      gasPrice: "auto",
      gas: "auto",
      accounts: [PRIVATE_KEY],
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: "auto",
      gas: "auto",
      accounts: [PRIVATE_PROD_KEY],
    },
    hardhat: {
      hardfork: "istanbul",
      blockGasLimit: DEFAULT_BLOCK_GAS_LIMIT,
      gas: DEFAULT_BLOCK_GAS_LIMIT,
      gasPrice: 8000000000,
      chainId: BUIDLEREVM_CHAINID,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      accounts: accounts.map(({ secretKey, balance }: { secretKey: string; balance: string }) => ({
        privateKey: secretKey,
        balance,
      })),
    },
    buidlerevm_docker: {
      hardfork: "istanbul",
      blockGasLimit: 9500000,
      gas: 9500000,
      gasPrice: 8000000000,
      chainId: BUIDLEREVM_CHAINID,
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      url: "http://localhost:8545",
    },
    ganache: {
      url: "http://ganache:8545",
      accounts: {
        mnemonic: "fox sight canyon orphan hotel grow hedgehog build bless august weather swarm",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
      },
    },
  },
};

export default buidlerConfig;
