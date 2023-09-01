# world-id-state-bridge

![spec](docs/state-bridge.svg)

## Description

State bridge between the WorldID Ethereum mainnet deployment and WorldID supported networks. The [spec](./docs/spec.md)
can be found in `docs/spec.md`.

## Deployments

The addresses of the contract deployments for production and staging can be found in
[`docs/deployments.md`](./docs/deployments.md#production).

## Supported networks

Currently, the supported networks are Polygon PoS (for backwards compatibility), Optimism and Base. The next iteration
of the bridge will most-likely be based on storage proofs and will support most EVM networks off the get-go, with other
networks pending storage proof verifier and Semaphore verifier implementations and deployments.

### Future integrations

If you want to support World ID on your network, please reach out to us by opening a GitHub issue. To support World ID
the current requirements are:

- have a native L1<>L2 bridge with Ethereum mainnet and Ethereum Goerli/Sepolia (for testnet integration tests)
- your network needs to have an EVM execution environment (like Optimism, Arbitrum, Scroll, Polygon zkEVM, zkSync Era,
  etc)

If your network meets these requirements, please reach out to us and we will work with you to integrate World ID. In the
mid-term future we plan on supporting storage proof solutions like [Axiom](https://axiom.xyz/) and
[Herodotus](https://herodotus.dev/) to bridge World ID state to other networks more seamlessly and with better UX and
for cheaper costs. Currently each bridge incurs the cost of each cross-chain message sent by calling the
`propagateRoot()` function. Subsidizing these costs on your end would make the integration process very simple.

If your network is not EVM-compatible/equivalent, a new implementation of the World ID contracts will need to be done
for your execution environment. Requirements are:

- Have a way to implement the `SemaphoreVerifier` and `semaphore-mtb` circuits verifier contracts which verify `Groth16`
  proofs over the `BN254` curve.
- Have the capabilities to support all cryptographic primitives that will be implemented in future versions of World ID
  as time goes on.
- Support the primitives needed to verify Axiom or Herodotus storage proofs.

For L1 to L1 bridges, there are solutions like [Succinct](https://succinct.xyz/)'s
[Telepathy](https://www.telepathy.xyz/) which have weaker security guarantees than storage proofs or native L1<>L2
bridges, but possibly allow for a World ID integration, provided that the reqirements above are met.

## Documentation

Run `make doc` to build and deploy a simple documentation webpage on [localhost:3000](https://localhost:3000). Uses
[`forge doc`](https://book.getfoundry.sh/reference/forge/forge-doc#forge-doc) under the hood and sources information
from the `world-id-state-bridge` contracts [NatSpec](https://docs.soliditylang.org/en/latest/natspec-format.html)
documentation.

## Usage

### Install Dependencies

```sh
make install
```

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

Format the contracts with `forge fmt` and the rest of the files (.js, .md) with Prettier:

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

### Deploy

Deploy the WorldID state bridge and all its components to Ethereum mainnet using the CLI tool. For a more detailed
description of the deployment process and production and staging (testnet) contract addresses, see
[deployments.md](./docs/deployments.md) .

Integration with full system:

1. Deploy [`world-id-contracts`](https://github.com/worldcoin/world-id-contracts)
2. Get deployment address for `WorldIDIdentityManager`
3. (optional) you can also use the `WorldIDIdentityManager` address that can be found in
   [`docs/deployments.md`](./docs/deployments.md) to bridge existing roots.
4. Deploy [`world-id-state-bridge`](https://github.com/worldcoin/world-id-state-bridge) by running `make deploy-testnet`
   (requires 2.)
5. Start inserting identities into the
   [`WorldIDIdentityManager`](https://github.com/worldcoin/world-id-contracts/blob/main/src/WorldIDIdentityManagerImplV1.sol)
6. Propagate roots from each StateBridge contract (`OpStateBridge` on Optimism and Base and `PolygonStateBridge`) to
   their bridged World ID counterparts (`OpWorldID` on Base and Optimism and `PolygonWorldID`) by individually calling
   `propagateRoot()` on each bridge contract using
   [`state-bridge-relay`](https://github.com/worldcoin/state-bridge-relay) or any other method of calling the public
   `propagateRoot()` functions on the respective state bridges. You can monitor `PolygonWorldID` and `OpWorldID`
   (Optimism/Base) for root updates either using a block explorer or some other monitoring service (Tenderly,
   OpenZeppelin Sentinel, DataDog, ...).
7. Try and create a proof and call `verifyProof` on `OpWorldID` (Optimism/Base) or `PolygonWorldID` to check whether
   everything works.

**Note:** Remember to call all functions that change state on these contracts via the owner address, which is the
deployer address by default.

#### Testnet

Deploy the WorldID state bridge and all its components to the Goerli testnet.

Integration with full system:

1. Deploy [`world-id-contracts`](https://github.com/worldcoin/world-id-contracts)
2. Get deployment address for `WorldIDIdentityManager`
3. (optional) you can also use the `WorldIDIdentityManager` address that can be found in
   [`docs/deployments.md`](./docs/deployments.md) to bridge existing roots.
4. Deploy [`world-id-state-bridge`](https://github.com/worldcoin/world-id-state-bridge) by running `make deploy-testnet`
   (requires 2.)
5. Start inserting identities into the
   [`WorldIDIdentityManager`](https://github.com/worldcoin/world-id-contracts/blob/main/src/WorldIDIdentityManagerImplV1.sol)
6. Propagate roots from each StateBridge contract (`OpStateBridge` on Optimism and Base and `PolygonStateBridge`) to
   their bridged World ID counterparts (`OpWorldID` on Base and Optimism and `PolygonWorldID`) by individually calling
   `propagateRoot()` on each bridge contract using
   [`state-bridge-relay`](https://github.com/worldcoin/state-bridge-relay) or any other method of calling the public
   `propagateRoot()` functions on the respective state bridges. You can monitor `PolygonWorldID` and `OpWorldID`
   (Optimism/Base) for root updates either using a block explorer or some other monitoring service (Tenderly,
   OpenZeppelin Sentinel, DataDog, ...).
7. Try and create a proof and call `verifyProof` on `OpWorldID` (Optimism/Base) or `PolygonWorldID` to check whether
   everything works.

**Note:** Remember to call all functions that change state on these contracts via the owner address, which is the
deployer address by default.

#### Mock

Deploy the WorldID state bridge and a mock WorldID identity manager to the Goerli testnet for integration tests.

```bash
# to do a mock of WorlIDIdentityManager and test bridge contracts on Goerli
make mock
```

#### Local Mock

For local mock tests use localhost:8545 as the RPC URL (or just hit enter to use it by default) and use any non-empty
string as the Etherscan API key (or just hit enter to use a placeholder by default).

Run a local anvil instance to deploy the contracts locally:

```bash
anvil --mnemonic <MNEMONIC> --network goerli --deploy
```

```bash
# meant for local testing, deploys mock contracts to localhost
make local-mock
```

## Credits

This repo uses Paul Razvan Berg's [foundry template](https://github.com/paulrberg/foundry-template/): A Foundry-based
template for developing Solidity smart contracts, with sensible defaults.
