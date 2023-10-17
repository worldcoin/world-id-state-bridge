# Deployment Guide

The deployment logic is implemented in [`src/script/deploy.js`](../src/script/deploy.js). The script is meant to be run
via the `make deploy`, `make deploy-testnet`, `make-mock` and `make-local-mock` commands. Here is a description of what
each of the deployment commands do and which forge scripts are executed:

- `make deploy` (`deploymentMainnet()` in `deploy.js`): Deploys the contracts to the production networks (Ethereum
  mainnet, Optimism mainnet, Base mainnet and Polygon PoS mainnet). The script executes the following:

  - generates the `src/script/.deploy-config.json` file with the deployment configuration
  - asks the user for a deployer address private key
  - asks for Ethereum, Optimism, Base and Polygon PoS RPC URLs
  - asks For [Ethereum](https://etherscan.io/login), [Optimism](https://optimistic.etherscan.io/login),
    [Base](https://basescan.org/login) and [Polygon PoS](https://polygonscan.com/login) Etherscan API keys for smart
    contract verification (uses `forge script` automatic verification on deployment)
  - asks for the WorldIDIdentityManager tree depth (currently hardcoded to 30 in `DeployOpWorldID` and
    `DeployPolygonWorldID` forge scripts found in `src/script/deploy`)
  - saves the above values to `.deploy-config.json`
  - deploys `OpWorldID.sol` to Optimism mainnet
    ([DeployOpWorldID.s.sol](../src/script/deploy/op-stack/DeployOpWorldID.s.sol))
  - deploys `OpWorldID.sol` to Base mainnet
    ([DeployOpWorldID.s.sol](../src/script/deploy/op-stack/DeployOpWorldID.s.sol))
  - deploys `PolygonWorldID.sol` to Polygon PoS mainnet
    ([DeployPolygonWorldIDMainnet.s.sol](../src/script/deploy/polygon/DeployPolygonWorldIDMainnet.s.sol))
  - prompts the user for the `WorldIDIdentityManager` address
  - asks for the deployment address of the `OpWorldID` contract on Optimism mainnet
  - asks for the deployment address of the `OpWorldID` contract on Base mainnet
  - asks for the deployment address of the `PolygonWorldID` contract on Polygon PoS mainnet
  - saves the above values to `.deploy-config.json`
  - deploys `PolygonStateBridge.sol` on Ethereum mainnet
    ([DeployPolygonStateBridgeMainnet.s.sol](../src/script/deploy/polygon/DeployPolygonStateBridgeMainnet.s.sol))
  - deploys `OpStateBridge.sol` (Optimism) on Ethereum mainnet
    ([DeployOptimismStateBridgeMainnet.s.sol](../src/script/deploy/op-stack/optimism/DeployOptimismStateBridgeMainnet.s.sol))
  - deploys `OpStateBridge.sol` (Base) on Ethereum mainnet
    ([DeployBaseStateBridgeMainnet.s.sol](../src/script/deploy/op-stack/base/DeployBaseStateBridgeMainnet.s.sol))
  - asks the user for the `OpStateBridge.sol` (Optimism) contract address
  - asks the user for the `OpStateBridge.sol` (Base) contract address
  - asks the user for the `PolygonStateBridge.sol` contract address
  - saves the above values to `.deploy-config.json`
  - initializes `PolygonWorldID.sol` with the `PolygonStateBridge.sol` contract address
    ([InitializePolygonWorldID.s.sol](../src/script/initialize/polygon/InitializePolygonWorldID.s.sol))
  - transfers ownership of `OpWorldID.sol` on Optimism mainnet to the `OpStateBridge.sol` (Optimism) contract on
    Ethereum mainnet using the `transferOwnership()` method in
    [`CrossDomainOwnable3.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/CrossDomainOwnable3.sol)
    ([TransferOpWorldIDOwnership.s.sol](../src/script/initialize/op-stack/optimism/LocalTransferOwnershipofOptimismWorldID.s.sol))
  - transfers ownership of `OpWorldID.sol` on Base mainnet to the `OpStateBridge.sol` (Base) contract on Ethereum
    mainnet using the `transferOwnership()` method in
    [`CrossDomainOwnable3.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/CrossDomainOwnable3.sol)
    ([TransferOpWorldIDOwnership.s.sol](../src/script/initialize/op-stack/base/LocalTransferOwnershipofBaseWorldID.s.sol))

- `make deploy-testnet` (`deploymentTestnet()` in `deploy.js`): Deploys the contracts to the production networks
  (Ethereum Goerli, Optimism Goerli, Base Goerli and Polygon PoS Mumbai). The script executes the following:

  - generates the `src/script/.deploy-config.json` file with the deployment configuration
  - asks the user for a deployer address private key
  - asks for Ethereum Goerli, Optimism Goerli, Base Goerli and Polygon PoS (Mumbai) RPC URLs
  - asks For [Ethereum](https://etherscan.io/login), [Optimism](https://optimistic.etherscan.io/login),
    [Base](https://basescan.org/login) and [Polygon PoS](https://polygonscan.com/login) Etherscan API keys for smart
    contract verification (uses `forge script` automatic verification on deployment)
  - asks for the WorldIDIdentityManager tree depth (currently hardcoded to 30 in `DeployOpWorldID` and
    `DeployPolygonWorldID` forge scripts found in `src/script/deploy`)
  - saves the above values to `.deploy-config.json`
  - deploys `OpWorldID.sol` to Optimism Goerli
    ([DeployOpWorldID.s.sol](../src/script/deploy/op-stack/DeployOpWorldID.s.sol))
  - deploys `OpWorldID.sol` to Base Goerli
    ([DeployOpWorldID.s.sol](../src/script/deploy/op-stack/DeployOpWorldID.s.sol))
  - deploys `PolygonWorldID.sol` to Polygon PoS Goerli
    ([DeployPolygonWorldIDMumbai.s.sol](../src/script/deploy/polygon/DeployPolygonWorldIDMumbai.s.sol))
  - prompts the user for the `WorldIDIdentityManager` address
  - asks for the deployment address of the `OpWorldID` contract on Optimism Goerli
  - asks for the deployment address of the `OpWorldID` contract on Base Goerli
  - asks for the deployment address of the `PolygonWorldID` contract on Polygon PoS Mumbai
  - saves the above values to `.deploy-config.json`
  - deploys `PolygonStateBridge.sol` on Ethereum Goerli
    ([DeployPolygonStateBridgeGoerli.s.sol](../src/script/deploy/polygon/DeployPolygonStateBridgeGoerli.s.sol))
  - deploys `OpStateBridge.sol` (Optimism) on Ethereum Goerli
    ([DeployOptimismStateBridgeGoerli.s.sol](../src/script/deploy/op-stack/optimism/DeployOptimismStateBridgeGoerli.s.sol))
  - deploys `OpStateBridge.sol` (Base) on Ethereum Goerli
    ([DeployBaseStateBridgeGoerli.s.sol](../src/script/deploy/op-stack/base/DeployBaseStateBridgeGoerli.s.sol))
  - asks the user for the `OpStateBridge.sol` (Optimism) contract address
  - asks the user for the `OpStateBridge.sol` (Base) contract address
  - asks the user for the `PolygonStateBridge.sol` contract address
  - saves the above values to `.deploy-config.json`
  - initializes `PolygonWorldID.sol` with the `PolygonStateBridge.sol` contract address
    ([InitializePolygonWorldID.s.sol](../src/script/initialize/polygon/InitializePolygonWorldID.s.sol))
  - transfers ownership of `OpWorldID.sol` on Optimism Goerli to the `OpStateBridge.sol` (Optimism) contract on Ethereum
    Goerli using the `transferOwnership()` method in
    [`CrossDomainOwnable3.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/CrossDomainOwnable3.sol)
    ([TransferOpWorldIDOwnership.s.sol](../src/script/initialize/op-stack/optimism/LocalTransferOwnershipofOptimismWorldID.s.sol))
  - transfers ownership of `OpWorldID.sol` on Base Goerli to the `OpStateBridge.sol` (Base) contract on Ethereum Goerli
    using the `transferOwnership()` method in
    [`CrossDomainOwnable3.sol`](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/CrossDomainOwnable3.sol)
    ([TransferOpWorldIDOwnership.s.sol](../src/script/initialize/op-stack/base/LocalTransferOwnershipofBaseWorldID.s.sol))

- `make mock` (`mockDeploymenth()` in `deploy.js`): Deploys the contracts to Ethereum Goerli and simulates the
  `WorldIdIdentityManager` contract.

  - same as `make deploy-testnet`, but also deploys a mock `WorldIDIdentityManager` contract to the Goerli testnet
    ([DeployMockWorldID.s.sol](../src/script/deploy/mock/DeployMockWorldID.s.sol))
  - can be used to test all the bridges and do integration tests as the mock will have a `sampleRoot` to propagate to
    all the supported chains using the state bridges by exposing the `latestRoot()` method to query a root the same way
    that `WorldIDIdentityManger` does.

- `make local-mock` (`mockLocalDeployment()` in `deploy.js`): Deploys the contracts to a local anvil instance, mocks the
  state bridge and the `WorldIDIdentityManager` contracts and tests the interface for propagating roots to a different
  chain by mocking cross-chain messaging and just keeping the right interfaces. Good for local development and testing.

  - when prompted for RPC URLs and Etherscan API keys, leave the field empty and press empty to use the default values
    (anvil's localhost:8545 endpoint for the RPC URL and a placeholder string for the Etherscan API key)
  - before running this script do `anvil --mnemonic <MNEMONIC>` and make sure that you are using one of the private keys
    provided by `anvil` for the script when being promted on the CLI.
  - good to test the generic function interface of the state bridges, the `WorldIDIdentityManager` contract, and the
    target chain World ID contract (`PolygonWorldID` / `OpWorldID`).
  - deploys a `MockWorldIDIdentityManager.sol` contract to the local anvil instance
    ([DeployMockWorldID.s.sol](../src/script/deploy/mock/DeployMockWorldID.s.sol))
  - inserts a sample root to the contract on deploy time (constructor param in the script above)
  - deploys a `MockStateBridge.sol` contract to the local anvil instance
    ([DeployMockStateBridge.s.sol](../src/script/deploy/mock/DeployMockStateBridge.s.sol))
  - propagates the sample root using `MockStateBridge.sol` contract to a `MockBridgedWorldID.sol` contract on the local
    anvil instance ([PropagateMockRoot.s.sol](../src/script/test/PropagateMockRoot.s.sol))

- `make set-op-gas-limit` (`setOpGasLimit` in `deploy.js`): Sets the gas limit for the `OpStateBridge.sol` contract on
  Ethereum mainnet/testnet. The gas limit purchased is for OP Stack L2 execution and calldata gas and is currently set
  to 100k gas, but can be changed if needed.

  - asks the user for the deployer private key (needs to be the owner of the `OpStateBridge.sol` contracts (Base and
    Optimism))
  - asks for the Ethereum RPC URL
  - asks for the `OpStateBridge.sol` (Optimism) contract address
  - asks for the `OpStateBridge.sol` (Base) contract address
  - asks for the new gas limits for different actions
  - sets the OP-stack `CrossDomainMessenger` gas limits for the `OpStateBridge.sol` contract on Ethereum mainnet/testnet
    using the `setGasLimitPropagateRoot()`, `setGasLimitSetRootHistoryExpiry()`, and`setGasLimitTransferOwnershipOp()`
    methods.

## Addresses of the production and staging deployments

### Orb - production on Ethereum mainnet (group id: 1)

Note: There is an upgrade to the production state bridge architecture currently running on staging which will be
performed once an audit of the changes are complete.

- WorldID State Bridge (Ethereum mainnet):
  [0x86d26ed31556ea7694bd0cc4e674d7526f70511a](https://etherscan.io/address/0x86d26ed31556ea7694bd0cc4e674d7526f70511a#code)
- OpWorldID (Optimism mainnet):
  [0x42ff98c4e85212a5d31358acbfe76a621b50fc02](https://optimistic.etherscan.io/address/0x42ff98c4e85212a5d31358acbfe76a621b50fc02#code)
- PolygonWorldID (Polygon PoS mainnet):
  [0x2Ad412A1dF96434Eed0779D2dB4A8694a06132f8](https://polygonscan.com/address/0x2Ad412A1dF96434Eed0779D2dB4A8694a06132f8#code)

### Orb - staging on Ethereum Goerli (group id: 1)

- Polygon State Bridge (Ethereum Goerli):
  [0x42Af76FB754ea23769Ad337bBC4456FD0893552f](https://goerli.etherscan.io/address/0x42Af76FB754ea23769Ad337bBC4456FD0893552f#code)
- Optimism State Bridge (Ethereum Goerli):
  [0x7acdc12cbcba53e1ea2206844d0a8ccb6f3b08fb](https://goerli.etherscan.io/address/0x7acdc12cbcba53e1ea2206844d0a8ccb6f3b08fb#code)
- Base State Bridge (Ethereum Goerli):
  [0x39911b3242e952d86270857bc8efc3fce8d84abe](https://goerli.etherscan.io/address/0x39911b3242e952d86270857bc8efc3fce8d84abe#code)
- PolygonWorldID (Polygon Mumbai):
  [0xB3E7771a6e2d7DD8C0666042B7a07C39b938eb7d](https://mumbai.polygonscan.com/address/0xB3E7771a6e2d7DD8C0666042B7a07C39b938eb7d#code)
- OpWorldID (Optimism Goerli):
  [0x316350d3ec608ffc30b01dcb7475de1c676ce910](https://goerli-optimism.etherscan.io/address/0x316350d3ec608ffc30b01dcb7475de1c676ce910#code)
- OpWorldID (Base Goerli):
  [0xa3cd15ebed6075e33a54483c59818bc43d57c556](https://goerli.basescan.org/address/0xa3cd15ebed6075e33a54483c59818bc43d57c556#code)
