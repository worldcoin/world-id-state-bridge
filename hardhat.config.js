/** @type import('hardhat/config').HardhatUserConfig */

require('@chugsplash/plugins')

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17" , // Solidity compiler version (e.g. 0.8.15)
        settings: {
          outputSelection: {
            '*': {
              '*': ['storageLayout'],
            },
          },
        },
      },
    ]
  }
}
