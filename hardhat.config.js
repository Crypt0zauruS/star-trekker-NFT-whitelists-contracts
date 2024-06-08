require("@nomicfoundation/hardhat-toolbox");
require("dotenv/config");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("@nomicfoundation/hardhat-verify");
require("@nomicfoundation/hardhat-foundry");

const POLYGON_RPC_URL = process.env.API_URL_KEY;
const AMOY_RPC_URL = process.env.API_TESTNET_URL_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "localhost",
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: false,
        runs: 200,
      },
    },
  },
  networks: {
    polygon: {
      url: POLYGON_RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 137,
    },
    amoy: {
      url: AMOY_RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 80002,
    },
  },
  sourcify: {
    enabled: true,
  },
  gasReporter: {
    enabled: true,
  },
  etherscan: {
    apiKey: POLYGONSCAN_API_KEY,
  },
};
