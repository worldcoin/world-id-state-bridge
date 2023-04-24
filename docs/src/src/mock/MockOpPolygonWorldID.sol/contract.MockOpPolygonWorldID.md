# MockOpPolygonWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/mock/MockOpPolygonWorldID.sol)

**Inherits:** [WorldIDBridge](/src/abstract/WorldIDBridge.sol/abstract.WorldIDBridge.md), Ownable

**Author:** Worldcoin

Mock of PolygonWorldID and OpWorldID in order to test functionality on a local chain

## Functions

### constructor

CONSTRUCTION ///

Initializes the contract the depth of the associated merkle tree.

```solidity
constructor(uint8 _treeDepth) WorldIDBridge(_treeDepth);
```

**Parameters**

| Name         | Type    | Description                                     |
| ------------ | ------- | ----------------------------------------------- |
| `_treeDepth` | `uint8` | The depth of the WorldID Semaphore merkle tree. |

### receiveRoot

ROOT MIRRORING ///

This function is called by the state bridge contract when it forwards a new root to the bridged WorldID.

_This function can revert if Optimism's CrossDomainMessenger stops processing proofs or if OPLabs stops submitting them.
Next iteration of Optimism's cross-domain messaging, will be fully permissionless for message-passing, so this will not
be an issue. Sequencer needs to include changes to the CrossDomainMessenger contract on L1, not economically penalized
if messages are not included, however the fraud prover (Cannon) can force the sequencer to include it._

```solidity
function receiveRoot(uint256 newRoot, uint128 supersedeTimestamp) public virtual;
```

**Parameters**

| Name                 | Type      | Description                                                                                                                                                                                       |
| -------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `newRoot`            | `uint256` | The value of the new root.                                                                                                                                                                        |
| `supersedeTimestamp` | `uint128` | The value of the L1 timestamp at the time that `newRoot` became the current root. This timestamp is associated with the latest root at the time of the call being inserted into the root history. |

### setRootHistoryExpiry

DATA MANAGEMENT ///

Sets the amount of time it takes for a root in the root history to expire.

```solidity
function setRootHistoryExpiry(uint256 expiryTime) public virtual override onlyOwner;
```

**Parameters**

| Name         | Type      | Description                                           |
| ------------ | --------- | ----------------------------------------------------- |
| `expiryTime` | `uint256` | The new amount of time it takes for a root to expire. |
