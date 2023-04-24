# PolygonWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/PolygonWorldID.sol)

**Inherits:** [WorldIDBridge](/src/abstract/WorldIDBridge.sol/abstract.WorldIDBridge.md), FxBaseChildTunnel, Ownable

**Author:** Worldcoin

A contract that manages the root history of the WorldID merkle root on Polygon PoS.

_This contract is deployed on Polygon PoS and is called by the StateBridge contract for each new root insertion._

## Functions

### constructor

CONSTRUCTION ///

Initializes the contract's storage variables with the correct parameters

```solidity
constructor(uint8 _treeDepth, address _fxChild)
    WorldIDBridge(_treeDepth)
    FxBaseChildTunnel(_fxChild);
```

**Parameters**

| Name         | Type      | Description                                                                                                                                                   |
| ------------ | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `_treeDepth` | `uint8`   | The depth of the WorldID Identity Manager merkle tree.                                                                                                        |
| `_fxChild`   | `address` | The address of the FxChild tunnel - the contract that will receive messages on Polygon and Broadcasts them to FxPortal which bridges the messages to Ethereum |

### \_processMessageFromRoot

ROOT MIRRORING ///

An internal function used to receive messages from the StateBridge contract.

_Calls `receiveRoot` upon receiving a message from the StateBridge contract via the FxChildTunnel. Can revert if the
message is not valid - decoding fails. Can not work if Polygon's StateSync mechanism breaks and FxPortal does not
receive the message on the other end._

```solidity
function _processMessageFromRoot(uint256, address sender, bytes memory message)
    internal
    override
    validateSender(sender);
```

**Parameters**

| Name      | Type      | Description                                                                                                 |
| --------- | --------- | ----------------------------------------------------------------------------------------------------------- |
| `<none>`  | `uint256` |                                                                                                             |
| `sender`  | `address` | The sender of the message.                                                                                  |
| `message` | `bytes`   | An ABI-encoded tuple of `(uint256 newRoot, uint128 supersedeTimestamp)` that is used to call `receiveRoot`. |

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

### setFxRootTunnel

TUNNEL MANAGEMENT ///

Sets the `fxRootTunnel` address if not already set.

_This implementation replicates the logic from `FxBaseChildTunnel` due to the inability to call `external` superclass
methods when overriding them._

```solidity
function setFxRootTunnel(address _fxRootTunnel) external virtual override onlyOwner;
```

**Parameters**

| Name            | Type      | Description                                   |
| --------------- | --------- | --------------------------------------------- |
| `_fxRootTunnel` | `address` | The address of the root (L1) tunnel contract. |
