# optimism-state-bridge

State bridge between Ethereum mainnet and the Optimism L2

### Spec

- [Optimism L1\<\>L2 communication](https://community.optimism.io/docs/developers/bridge/messaging/) documentation
- root hashes (validity associated - e.g. 1 week - timestamp + expiry)
  - valid until newer hash or newer hash, but timestamp is recent
- simple
  - replicate all root hashes from L1 to L2
  - L2 contract has access to root hashes and timestamps
  - Opt. 1.: Push Based - Semaphore pushes on each state root update to Optimism L2
    - Downsides:
      - Hard to scale, redeploying semaphore, separate impls for diff L2s
    - TODO:
      - Figure out costs of scale
  - Opt. 2.: Pull based, CRON - proxy contract you can send state roots, checks against semaphore if they are correct and proceeds to send them to L2s. Service like Gelato periodically fetches latest state roots and checks agains semaphore before submitting to proxy
  - Opt.3. Pull based, external service - -""-, external service makes sure that latest root hashes are correct, and handles errors on its own. EOA, funded by us, sends txs to proxy with updated roots.
    - TODO:
      - batching: multiple roots in 1 call
      - look into what changes are required on Semaphore contract in order to make opt.3. work, so if opt.1. ends up being chosen, developments don't make opt.3. infeasible
  - opt.1. initially, can later migrate to opt.3. (L2 agnostic)
- next steps:
  - turn spec into well-defined tasks, time estimates, features, roadmap, plan

### Optimism L1<>L2 infrastructure

An Optimism L2 node is required to run the state bridge. The L2 node is used to fetch the latest state root from the L1 contract and submits it to the L2 contract. So if we want to send a message to the messenger on L1, that triggers a change in the canonical Optimism state that the Optimism sequencer has to include as a transaction on the L2. That state transition goes through the fault proof mechanism so that if its not included in the L2, the sequencer can be forced to include it by the fault proof mechanism (even economically punished in future iterations of the protocol). Current time to relay message (estimation for Bedrock) is around 2 minutes for a message from L1 to L2. Worst case scenario can be up to a couple of hours if sequencer is malicious and willingly doesn't want to include the transition. More info in the Optimism whitepaper.
