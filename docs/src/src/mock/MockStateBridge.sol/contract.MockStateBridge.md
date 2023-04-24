# MockStateBridge

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/mock/MockStateBridge.sol)

**Inherits:** Ownable

**Author:** Worldcoin

Mock of the StateBridge to test functionality on a local chain

## State Variables

### mockOpPolygonWorldIDAddress

The address of the MockOpPolygonWorldID contract

```solidity
address public mockOpPolygonWorldIDAddress;
```

### worldIDAddress

Interface for checkValidRoot within the WorldID Identity Manager contract

```solidity
address public worldIDAddress;
```

### worldID

```solidity
IWorldIDIdentityManager internal worldID;
```

## Functions

### constructor

constructor

```solidity
constructor(address _worldIDIdentityManager, address _mockOpPolygonWorldIDAddress);
```

**Parameters**

| Name                           | Type      | Description                                                                 |
| ------------------------------ | --------- | --------------------------------------------------------------------------- |
| `_worldIDIdentityManager`      | `address` | Deployment address of the WorldID Identity Manager contract                 |
| `_mockOpPolygonWorldIDAddress` | `address` | Address of the MockOpPolygonWorldID contract for the new root and timestamp |

### sendRootMultichain

Sends the latest WorldID Identity Manager root to all chains.

_Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains._

```solidity
function sendRootMultichain(uint256 root) public;
```

**Parameters**

| Name   | Type      | Description                               |
| ------ | --------- | ----------------------------------------- |
| `root` | `uint256` | The latest WorldID Identity Manager root. |

### \_sendRootToMockOpPolygonWorldID

_Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains._

```solidity
function _sendRootToMockOpPolygonWorldID(uint256 root, uint128 timestamp) internal;
```

**Parameters**

| Name        | Type      | Description                                                               |
| ----------- | --------- | ------------------------------------------------------------------------- |
| `root`      | `uint256` | The latest WorldID Identity Manager root.                                 |
| `timestamp` | `uint128` | The Ethereum block timestamp of the latest WorldID Identity Manager root. |

## Errors

### InvalidRoot

Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract

```solidity
error InvalidRoot();
```
