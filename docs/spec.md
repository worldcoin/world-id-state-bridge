# State Bridge spec

![state-bridge.svg](state-bridge.svg)

Propagates new World ID merkle tree roots from the `WorldIDIdentityManager` contract
([`world-id-contracts`](https://github.com/worldcoin/world-id-contracts) repo) on Ethereum mainnet to Optimism and
Polygon PoS.

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
