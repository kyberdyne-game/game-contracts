import {HardhatUserConfig} from 'hardhat/config'
import * as fs from 'fs'
import * as path from 'path'
import "@nomiclabs/hardhat-ethers";

require("@nomiclabs/hardhat-waffle");

require('hardhat-storage-layout');

const bsc_mnemonic = fs.readFileSync(path.resolve('./bsc.mnemonic')).toString().trim();

const exp: HardhatUserConfig = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            accounts: {
                mnemonic: 'test test test test test test test test test test test junk',
                initialIndex: 0,
                path: "m/44'/60'/0'/0",
                count: 20,
                accountsBalance: "10000000000000000000000",
            },
            throwOnTransactionFailures: true,
            throwOnCallFailures: true,
            allowUnlimitedContractSize: false,
            //gas:60000000,
            blockGasLimit: 60000000,
        },

        ganache: {
            url: "http://127.0.0.1:8545",
            //chainId: 5777,
            //1Gwei
            gasPrice: 1000000000,
            accounts: {
                mnemonic: 'test test test test test test test test test test test junk',
                initialIndex: 0,
                path: "m/44'/60'/0'/0",
                count: 20,
            },
            timeout: 20 * 1000,
            gasMultiplier: 2
        },

        bsc: {
            url: "https://bsc-dataseed.binance.org/",
            //url:"https://bsc-dataseed1.defibit.io/",
            //url:"https://bsc-dataseed1.ninicoin.io",
            //url:"https://bsc-dataseed2.defibit.io/",
            //url:"https://bsc-dataseed3.defibit.io/",
            //url:"https://bsc-dataseed4.defibit.io/",
            //url:"https://bsc-dataseed2.ninicoin.io",
            //url:"https://bsc-dataseed3.ninicoin.io",
            //url:"https://bsc-dataseed4.ninicoin.io",
            //url:"https://bsc-dataseed1.binance.org",
            //url:"https://bsc-dataseed2.binance.org",
            //url:"https://bsc-dataseed3.binance.org",
            //url:"https://bsc-dataseed4.binance.org",
            chainId: 56,
            //5gwei
            gasPrice: 5500000000,
            accounts: {
                mnemonic: bsc_mnemonic,
                initialIndex: 0,
                path: "m/44'/60'/0'/0",
                count: 20,
            },
            timeout: 20 * 1000,
            gasMultiplier: 1.1
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.4.26",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
            {
                version: "0.5.16",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
            {
                version: "0.6.6",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
            {
                version: "0.6.12",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
            {
                version: "0.7.4",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
            {
                version: "0.8.11",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    },
                    outputSelection: {
                        "*": {
                            "*": ["storageLayout"],
                        },
                    },
                }
            },
        ]
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    mocha: {
        timeout: 0,
        bail: true,
        color: true,
    }
};

export default exp
