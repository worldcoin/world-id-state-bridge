# world-id-state-bridge

![spec](./docs/state-bridge.svg)

## Description


State bridge between the WorldID Ethereum mainnet deployment and WorldID supported networks. The [spec](./docs/spec.md) can be found in `docs/spec.md`.

## Supported networks

Currently, the supported networks are Polygon PoS (for backwards compatibility) and Optimism. The next iteration of the bridge will most-likely be based on storage proofs and will support most EVM networks off the get-go, with other networks pending storage proof verifier and Semaphore verifier implementations and deployments.

## Usage

### Build

Build the contracts:

```sh
forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
forge clean
```

### Coverage

Get a test coverage report:

```sh
forge coverage
```

### Format

Format the contracts with Prettier:

```sh
yarn format
yarn prettier
```

### Gas Usage

Get a gas report:

```sh
forge test --gas-report
```

### Lint

Lint the contracts:

```sh
yarn lint
```

### Test

Run the tests:

```sh
forge test
```

### Environment

Clone `.env.example` to `.env`, fill the environment variables and `source .env` before running any scripts. Beware that there is a different
Etherscan API key for every single network that we are deploying a contract onto (Ethereum, Polygon and Optimism - mainnet/testnet).

### Deploy

#### Testnet

Deploy to Goerli:

`StateBridge`:

```sh
forge script script/deploy/DeployStateBridgeGoerli.s.sol --fork-url $GOERLI_URL \
 --broadcast --verify -vvvv
```

`world-id-contracts`:

Mock:

```sh
forge script script/deploy/DeployMockWorldID.s.sol --fork-url $GOERLI_URL \
 --broadcast --verify -vvvv
```

Integration with full system:

- Download [`world-id-contracts`](https://github.com/worldcoin/world-id-contracts)
- `make all`
- edit constants in `deploy.js` to configure it to deploy on Goerli (`RPC_URL`)
- `make deploy`
- follow the deployment script guide in the command line and input the deployment address of `StateBridge` when prompted.

`OpWorldID`:

Make sure to uncomment the correct Etherscan API key in `.env` and `source .env` before deploying.
Put the `StateBridge` deployment address in the constructor of `OpWorldID` in the deployment `DeployOpWorldID.s.sol` script.

```sh
forge script script/deploy/DeployStateBridgeGoerli.s.sol --fork-url $OP_GOERLI_URL \
 --broadcast --verify -vvvv
```

`PolygonWorldID`:

Make sure to uncomment the correct Etherscan API key in `.env` and `source .env` before deploying.
Put the `StateBridge` deployment address in the constructor of `PolygonWorldID` in the deployment `DeployPolygonWorldID.s.sol` script.

```sh
forge script script/deploy/DeployPolygonWorldID.s.sol --fork-url $POLYGON_MUMBAI_URL \
 --broadcast --verify -vvvv
```

### Initialize

After deploying all of the contracts, you need to update the address in the initialization scripts in order to make sure that the `StateBridge` is able to communicate with the correct target contracts.

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting tutorial](https://book.getfoundry.sh/tutorials/solidity-scripting.html).

## Credits

This repo uses Paul Razvan Berg's [foundry template](https://github.com/paulrberg/foundry-template/): A Foundry-based template for developing Solidity smart contracts, with sensible defaults.
