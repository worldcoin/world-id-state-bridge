# Spec

1. Push-based approach (current v0.1.0)

- `registerIdentities` in `Semaphore.sol` calls a method in the `Bridge.sol` contract that sends over each new state root and its timestamp. The root and the timestamp get sent from `Bridge.sol` to the `OpWorldID.sol` contract on the Optimism L2 which accepts them in order to allow developers on Optimism to call `verifyProof` on WorldID actions. In order to insert a new root in `OpWorldID.sol` the `Bridge.sol` contract needs to provide a storage proof of the state of the `rootHistory` mapping in `Semaphore.sol` to certify that the newly inserted root is indeed valid. `Semaphore.sol` also needs to have an ugpradeability mechanism for `stateBridge`.

- Downsides:
  - Hard to scale, redeploying semaphore, separate impls for diff L2s

2. Pull-based approach (CRON)

- idea: proxy contract you can send state roots, checks against semaphore if they are correct and proceeds to send them to L2s. Service like Gelato periodically fetches latest state roots and checks agains semaphore before submitting to proxy

3. Pull-based approach (external service)

- idea: external service makes sure that latest root hashes are correct, and handles errors on its own. EOA, funded by us, sends txs to proxy with updated roots.
- TODO:
  - batching: multiple roots in 1 call
  - look into what changes are required on Semaphore contract in order to make opt.3. work, so if opt.1. ends up being chosen, developments don't make opt.3. infeasible

## Optimism L1<>L2 infrastructure

Assumption: Optimism Bridge currently relies on OP labs submitting output commitments, however they are working on making it fully permissionless so that anyone can submit their own output commitment. The L2 node is used to fetch the latest state root from the L1 contract and submits it to the L2 contract. So if we want to send a message to the messenger on L1, that triggers a change in the canonical Optimism state that the Optimism sequencer has to include as a transaction on the L2. That state transition goes through the fault proof mechanism so that if its not included in the L2, the sequencer can be forced to include it by the fault proof mechanism (even economically punished in future iterations of the protocol). Current time to relay message (estimation for Bedrock) is around 2 minutes for a message from L1 to L2. Worst case scenario can be up to a couple of hours if sequencer is malicious and willingly doesn't want to include the transition. More info in the Optimism whitepaper.
