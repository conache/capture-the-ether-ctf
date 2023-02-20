require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");
require("hardhat-contract-sizer");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
      { version: "0.4.21" },
    ],
  },
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_RPC_URL,
      accounts: [process.env.ACCOUNT_1_PK, process.env.ACCOUNT_2_PK],
    },
    defaultNetwork: {
      url: "hardhat",
    },
  },
};
