# world-id-state-bridge

![spec](https://raw.githubusercontent.com/worldcoin/world-id-state-bridge/2cba98da38cfc5173ad773824126ce4285d240b1/docs/state-bridge.svg)

## Description

State bridge between the WorldID Ethereum mainnet deployment and WorldID supported networks. The [spec](./docs/spec.md)
can be found in `docs/spec.md`.

## Supported networks

Currently, the supported networks are Polygon PoS (for backwards compatibility) and Optimism. The next iteration of the
bridge will most-likely be based on storage proofs and will support most EVM networks off the get-go, with other
networks pending storage proof verifier and Semaphore verifier implementations and deployments.

## Usage

### Build

Build the contracts:

```sh
make build
```

### Clean

Delete the build artifacts and cache directories:

```sh
make clean
```

### Coverage

Get a test coverage report:

```sh
make coverage
```

### Format

Format the contracts with Prettier:

```sh
make format
```

### Gas Usage

Get a gas report:

```sh
make snapshot
```

```sh
make bench
```

### Lint

Lint the contracts:

```sh
make lint
```

### Test

Run the tests:

```sh
make test
```

### Environment

Clone `.env.example` to `.env`, fill the environment variables and `source .env` before running any scripts. Beware that
there is a different Etherscan API key for every single network that we are deploying a contract onto
([Ethereum](https://etherscan.io/myaccount), [Polygon](https://polygonscan.com/myaccount) and
[Optimism](https://optimistic.etherscan.io/login)- mainnet/testnet).

### Deploy

Deploy the WorldID state bridge and all its components to Ethereum mainnet using the CLI tool.

```sh
make deploy
```

Integration with full system:

- Download [`world-id-contracts`](https://github.com/worldcoin/world-id-contracts)
- `make deploy`
- follow the CLI interface for the deployment script and select Ethereum mainnet as the target deployment network, and
  input the deployment address of `StateBridge` when prompted.

#### Testnet

Deploy the WorldID state bridge and all its components to the Goerli testnet.

```sh
make deploy-testnet
```

Integration with full system:

- Download [`world-id-contracts`](https://github.com/worldcoin/world-id-contracts)
- `make deploy`
- follow the CLI interface for the deployment script and select Goerli as the target deployment network, and input the
  deployment address of `StateBridge` when prompted.

#### Mock

Deploy the WorldID state bridge and a mock WorldID identity manager to the Goerli testnet for integration tests.

```sh
make mock
```

### Integration test

<!-- WIP -->

```sh
make integration
```

## Credits

This repo uses Paul Razvan Berg's [foundry template](https://github.com/paulrberg/foundry-template/): A Foundry-based
template for developing Solidity smart contracts, with sensible defaults.
