# world-id-state-bridge

![spec](./docs/state-bridge.svg)

## Description


State bridge between the WorldID Ethereum mainnet deployment and WorldID supported networks. The [spec](./docs/spec.md) can be found in `docs/spec.md`.

## Supported networks

Currently, the supported networks are Polygon PoS (for backwards compatibility) and Optimism. The next iteration of the bridge will most-likely be based on storage proofs and will support most EVM networks off the get-go, with other networks pending storage proof verifier and Semaphore verifier implementations and deployments.

## Usage

### Environment

Clone `.env.example` to `.env`, fill the environment variables and `source .env` before running any scripts.

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

### Compile

Compile the contracts:

```sh
forge build
```

### Coverage

Get a test coverage report:

```sh
forge coverage
```

### Deploy

#### Goerli

Deploy to Goerli:

```sh
forge script script/deploy/DeployStateBridgeGoerli.s.sol --fork-url $GOERLI_URL \
 --broadcast --private-key $PRIVATE_KEY
```

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting tutorial](https://book.getfoundry.sh/tutorials/solidity-scripting.html).

### Format

Format the contracts with Prettier:

```sh
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

For instructions on how to deploy to a testnet or mainnet, check out the
[Solidity Scripting tutorial](https://book.getfoundry.sh/tutorials/solidity-scripting.html).

### Format

Format the contracts with Prettier:

```sh
$ yarn prettier
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Lint

Lint the contracts:

```sh
$ yarn lint
```

### Test

Run the tests:

```sh
$ forge test
```

## Credits
This repo uses Paul Razvan Berg's [foundry template](https://github.com/paulrberg/foundry-template/): A Foundry-based template for developing Solidity smart contracts, with sensible defaults.
