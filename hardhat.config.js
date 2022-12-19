require("@nomicfoundation/hardhat-toolbox");
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');
require("dotenv").config();

const privateKey = process.env.PRIVATE_KEY;
const goerliurl  = process.env.GOERLI_URL;
const etherscanKey = process.env.ETHERSCAN_API_KEY;
const polygonscanKey = process.env.POLYGON_SCAN_KEY;
const mumbaiurl = process.env.MUMBAI_URL;
const binanceurl = process.env.BINANCE_URL;
const binancescanKey = process.env.BINANCE_KEY;

module.exports = {
  
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks:{
    goerli:{
      url:goerliurl,
      chainId:5,
      accounts:[`0x${privateKey}`]
    },
    mumbai: {
      url: mumbaiurl,
      chainId:80001,
      accounts: [`0x${privateKey}`]
    },
   bscTestnet:{
    url: binanceurl,
    chainId:97,
    accounts: [`0x${privateKey}`]
   }
  },

  etherscan:{
    apiKey:etherscanKey,

  }
};
