const DotEnv = require('dotenv')
DotEnv.config()

const HDWalletProvider = require('@truffle/hdwallet-provider');
const infuraKey = process.env.INFURA_KEY;
const mnemonic = process.env.MNEMONIC;
const etherscanKey = process.env.ETHERSCAN_KEY;

module.exports = {
  plugins:[
    'truffle-plugin-verify',
    "truffle-contract-size"
  ],
  api_keys: {
    etherscan: etherscanKey
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*"
     },
     kovan: {
      provider: () => new HDWalletProvider(mnemonic, `https://kovan.infura.io/v3/${infuraKey}`),
      network_id: 42,          
      confirmations: 2,    
      timeoutBlocks: 400,  
      gasPrice:130000000000,
      skipDryRun: true
    },

    ropsten: {
      provider: () => new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`),
      network_id: 3,
      confirmations: 2,
      timeoutBlocks: 400,
      gasPrice:130000000000,
      skipDryRun: true 
    },

    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${infuraKey}`),
      network_id: 1,       
      confirmations: 1,
      gasPrice:180000000000,
      timeoutBlocks: 400,
      skipDryRun: true 
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0",    
      settings: {          
       optimizer: {
         enabled: false,
         runs: 200
       },
       evmVersion: "byzantium"
      }
    }
  },
  db: {
    enabled: false
  }

};
