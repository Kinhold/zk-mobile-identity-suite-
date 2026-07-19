require("dotenv").config({ quiet: true });

/** @type import("hardhat/config").HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.27",
    settings: {
      evmVersion: "shanghai",
      optimizer: {
        enabled: true,
        // Favor deployable verifier bytecode over repeated-call gas savings.
        runs: 1,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./contracts/test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  networks: {
    arbitrumSepolia: {
      url: process.env.ARB_SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    ethereumSepolia: {
      url: process.env.ETH_SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
};
