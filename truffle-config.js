require('dotenv').config()
const HDWalletProvider = require('@truffle/hdwallet-provider')

const mochaGasSettings = {
  reporter: 'eth-gas-reporter',
  reporterOptions: {
    currency: 'USD',
    gasPrice: 3,
  },
}

const mochaArguments = process.env.GAS_REPORTER ? mochaGasSettings : {}
module.exports = {
  // Uncommenting the defaults below 
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
    dev: {
      host: '127.0.0.1',
      port: 9545,
      network_id: '*',
      "constantinopleBlock": 0,
      "petersburgBlock": 0,
    },
    // development: {
    //   host: '127.0.0.1',
    //   port: 8545,
    //   network_id: 20,
    //   accounts: 5,
    //   defaultEtherBalance: 500,
    //   blockTime: 3
    // },
    test: {
      provider: function() {
        return new HDWalletProvider([process.env.PRIVATE_KEY], "http://127.0.0.1:7545/");
      },
      network_id: "5777"
    },
    goerli: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://goerli.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: '5', // eslint-disable-line camelcase
      gas: 4465030,
      gasPrice: 10000000000,
    },
    ropsten: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://ropsten.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: '3', // eslint-disable-line camelcase
      gas: 4465030,
      gasPrice: 10000000000,
    },
    kovan: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://kovan.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: '42', // eslint-disable-line camelcase
      gas: 4465030,
      gasPrice: 10000000000,
    },
    rinkeby: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://rinkeby.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: 4, // eslint-disable-line camelcase
      gas: 3000000,
      gasPrice: 10000000000,
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xffffffffff,
      gasPrice: 0x01,
    },
    // main ethereum network(mainnet)
    main: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, 'https://mainnet.infura.io/v3/' + process.env.INFURA_API_KEY)
      },
      network_id: 1, // eslint-disable-line camelcase
      gas: 3000000,
      gasPrice: 10000000000,
    },
  },
  //
  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows: 
  // $ truffle migrate --reset --compile-all
  //
  // db: {
    // enabled: false,
    // host: "127.0.0.1",
    // adapter: {
    //   name: "sqlite",
    //   settings: {
    //     directory: ".db"
    //   }
    // }
  // }
  compilers: {
    solc: {
      version: "^0.8.7"
    }
  }
};
