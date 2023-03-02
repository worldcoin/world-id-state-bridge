# State Bridge spec

## Design iteration

1. Push-based approach (current - v0.1.0)

- [`registerIdentities`](https://github.com/worldcoin/world-id-contracts/blob/98f4d6ae959a5a8a3c5ad5b57086e01d999d1b83/src/WorldIDIdentityManagerImplV1.sol#L288-L355)
  in
  [`WorldIDIdentityManagerImplV1.sol`](https://github.com/worldcoin/world-id-contracts/src/WorldIDIdentityManagerImplV1.sol)
  calls a method in the [`StateBridge.sol`](../src/StateBridge.sol) contract that sends over each new state root and its
  timestamp.

- Downsides:
  - Hard to scale, redeploying semaphore, separate impls for diff L2s

2. Pull-based approach (CRON)

- status: archived
- idea: proxy contract you can send state roots, checks against semaphore if they are correct and proceeds to send them
  to L2s. Service like Gelato periodically fetches latest state roots and checks agains semaphore before submitting to
  proxy

3. Pull-based approach (external service)

- status: ideation, strong candidate the for next iteration of the state bridge functionality
- idea: leverage storage proofs of `WorldIDIdentityManager` contract on L1 and run an external relayer service that
  would update all of the supported target chain contracts by providing a new root, the block timestamp and a storage
  proof from Ethereum mainnet. This approach is easily generalizable to any target chain that supports the cryptography
  needed to deploy a Semaphore verifier and a storage proof verifier. For EVM-based chain it is a trivial change as
  contracts for this are already implemented and would only require a \<targetChain\>WorldID contract deployment and
  integration to the state relayer service.

- Upsides:
  - generalizeable
  - proper solution (conceptually simpler, no ownability required)
- Downsides:
  - non-trivial implementation for storage proofs on non-EVM chains

## Structure

![state-bridge.svg](state-bridge.svg)

Currently the state bridge supports Optimism and Polygon PoS. The root and the timestamp get sent from
[`StateBridge.sol`](../src/StateBridge.sol) to the [`OpWorldID.sol`](../src/OpWorldID.sol) contract on the Optimism L2
which accepts them in order to allow developers on Optimism to call `verifyProof` on [WorldID](https://id.worldcoin.org)
actions. The same applies for the [`PolygonWorldID.sol`](../src/PolygonWorldID.sol) contract. Both of these contracts
have a `require()` statement which checks whether the `StateBridge.sol` contract is the originator of the call to
`receiveRoot()`. This means that only the `StateBridge.sol` contract is able to push new roots to the target WorldID
contracts on Optimism and Polygon PoS. In the future, this mechanism will be replaced by introducing a public method
with a storage proof verifier that will verify the latest `eth_getProof` storage proof on the target network.

## Polygon PoS state transfer infrastructure

In order to bridge state from Ethereum to Polygon the `world-id-state-bridge` is currently using the
[FxPortal contracts](https://wiki.polygon.technology/docs/develop/l1-l2-communication/fx-portal/). It takes about 20
minutes to sync the state from the state bridge to the `PolygonWorldID.sol` contract and about 1 hour to checkpoint said
state to the Polygon bridge on L1.

## Optimism L1<>L2 infrastructure

The `StateBridge.sol` uses Optimism's native bridge contract and `L2Messenger` to relay messages from L1 to L2. A guide
can be found in the [Optimism documentation](https://community.optimism.io/docs/developers/bridge/messaging/) to learn
more about how this mechanism works.

Assumption: Optimism Bridge currently relies on OP labs submitting output commitments, however they are working on
making it fully permissionless so that anyone can submit their own output commitment. The L2 node is used to fetch the
latest state root from the L1 contract and submits it to the L2 contract. So if we want to send a message to the
messenger on L1, that triggers a change in the canonical Optimism state that the Optimism sequencer has to include as a
transaction on the L2. That state transition goes through the fault proof mechanism so that if its not included in the
L2, the sequencer can be forced to include it by the fault proof mechanism (even economically punished in future
iterations of the protocol). Current time to relay message (estimation for Bedrock) is around 2 minutes for a message
from L1 to L2. Worst case scenario can be up to a couple of hours if sequencer is malicious and willingly doesn't want
to include the transition.
