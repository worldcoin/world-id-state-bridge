# StateBridge

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/StateBridge.sol)

**Inherits:** FxBaseRootTunnel, Ownable

**Author:** Worldcoin

Distributes new World ID Identity Manager roots to World ID supported networks

_This contract lives on Ethereum mainnet and is called by the World ID Identity Manager contract in the
registerIdentities method_

## State Variables

### opWorldIDAddress

The address of the OPWorldID contract on Optimism

```solidity
address public opWorldIDAddress;
```

### crossDomainMessengerAddress

address for Optimism's Ethereum mainnet L1CrossDomainMessenger contract

```solidity
address internal crossDomainMessengerAddress;
```

### worldID

Interface for checkVlidRoot within the WorldID Identity Manager contract

```solidity
IWorldIDIdentityManager internal worldID;
```

### worldIDAddress

worldID Address

```solidity
address public worldIDAddress;
```

## Functions

### constructor

constructor

```solidity
constructor(
    address _checkpointManager,
    address _fxRoot,
    address _worldIDIdentityManager,
    address _opWorldIDAddress,
    address _crossDomainMessenger
) FxBaseRootTunnel(_checkpointManager, _fxRoot);
```

**Parameters**

| Name                      | Type      | Description                                                                           |
| ------------------------- | --------- | ------------------------------------------------------------------------------------- |
| `_checkpointManager`      | `address` | address of the checkpoint manager contract                                            |
| `_fxRoot`                 | `address` | address of Polygon's fxRoot contract, part of the FxPortal bridge (Goerli or Mainnet) |
| `_worldIDIdentityManager` | `address` | Deployment address of the WorldID Identity Manager contract                           |
| `_opWorldIDAddress`       | `address` | Address of the Optimism contract that will receive the new root and timestamp         |
| `_crossDomainMessenger`   | `address` | L1CrossDomainMessenger contract used to communicate with the Optimism network         |

### sendRootMultichain

Sends the latest WorldID Identity Manager root to all chains.

_Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains._

```solidity
function sendRootMultichain(uint256 root) external;
```

**Parameters**

| Name   | Type      | Description                               |
| ------ | --------- | ----------------------------------------- |
| `root` | `uint256` | The latest WorldID Identity Manager root. |

### \_sendRootToOptimism

Sends the latest WorldID Identity Manager root to all chains.

_Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains._

```solidity
function _sendRootToOptimism(uint256 root, uint128 timestamp) internal;
```

**Parameters**

| Name        | Type      | Description                                                               |
| ----------- | --------- | ------------------------------------------------------------------------- |
| `root`      | `uint256` | The latest WorldID Identity Manager root.                                 |
| `timestamp` | `uint128` | The Ethereum block timestamp of the latest WorldID Identity Manager root. |

### transferOwnershipOptimism

Adds functionality to the StateBridge to transfer ownership of OpWorldID to another contract on L1 or to a local
Optimism EOA

```solidity
function transferOwnershipOptimism(address _owner, bool _isLocal) public onlyOwner;
```

**Parameters**

| Name       | Type      | Description                                                           |
| ---------- | --------- | --------------------------------------------------------------------- |
| `_owner`   | `address` | new owner (EOA or contract)                                           |
| `_isLocal` | `bool`    | true if new owner is on Optimism, false if it is a cross-domain owner |

### \_sendRootToPolygon

POLYGON ///

Sends root and timestamp to Polygon's StateChild contract (PolygonWorldID)

```solidity
function _sendRootToPolygon(uint256 root, uint128 timestamp) internal;
```

**Parameters**

| Name        | Type      | Description                                                              |
| ----------- | --------- | ------------------------------------------------------------------------ |
| `root`      | `uint256` | The latest WorldID Identity Manager root to be sent to Polygon           |
| `timestamp` | `uint128` | The Ethereum block timestamp of the latest WorldID Identity Manager root |

### \_processMessageFromChild

FxBaseRootTunnel method to send bytes payload to FxBaseChildTunnel contract

boilerplate function to satisfy FxBaseRootTunnel inheritance (not going to be used)

```solidity
function _processMessageFromChild(bytes memory) internal override;
```

### setFxChildTunnel

WorldID 🌎🆔 State Bridge TUNNEL MANAGEMENT ///

Sets the `fxChildTunnel` address if not already set.

_This implementation replicates the logic from `FxBaseRootTunnel` due to the inability to call `external` superclass
methods when overriding them._

```solidity
function setFxChildTunnel(address _fxChildTunnel) public virtual override onlyOwner;
```

**Parameters**

| Name             | Type      | Description                                        |
| ---------------- | --------- | -------------------------------------------------- |
| `_fxChildTunnel` | `address` | The address of the child (non-L1) tunnel contract. |

## Events

### OwnershipTransferredOptimism

Emmitted when the the StateBridge gives ownership of the OPWorldID contract to the WorldID Identity Manager contract
away

```solidity
event OwnershipTransferredOptimism(
    address indexed previousOwner, address indexed newOwner, bool isLocal
);
```

### RootSentToOptimism

Emmitted when a root is sent to OpWorldID

```solidity
event RootSentToOptimism(uint256 root, uint128 timestamp);
```

### RootSentToPolygon

Emmitted when a root is sent to PolygonWorldID

```solidity
event RootSentToPolygon(uint256 root, uint128 timestamp);
```

## Errors

### NotWorldIDIdentityManager

Thrown when the caller of `sendRootMultichain` is not the WorldID Identity Manager contract.

```solidity
error NotWorldIDIdentityManager();
```
