# StateBridgeTest

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/test/StateBridge.t.sol)

**Inherits:** PRBTest, StdCheats

## State Variables

### mainnetFork

```solidity
uint256 public mainnetFork;
```

### MAINNET_RPC_URL

```solidity
string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
```

### stateBridge

```solidity
StateBridge public stateBridge;
```

### mockWorldID

```solidity
WorldIDIdentityManagerMock public mockWorldID;
```

### mockWorldIDAddress

```solidity
address public mockWorldIDAddress;
```

### crossDomainMessengerAddress

```solidity
address public crossDomainMessengerAddress;
```

### fxRoot

```solidity
address public fxRoot;
```

### checkpointManager

```solidity
address public checkpointManager;
```

### owner

```solidity
address public owner;
```

## Functions

### setUp

```solidity
function setUp() public;
```

### test_canSelectFork_succeeds

Create a fork of the Ethereum mainnet

Roll the fork to the block where Optimim's crossDomainMessenger contract is deployed

select a specific fork

```solidity
function test_canSelectFork_succeeds() public;
```

### test_sendRootMultichain_succeeds

```solidity
function test_sendRootMultichain_succeeds(uint256 newRoot) public;
```

### test_owner_transferOwnership_succeeds

tests whether the owner of the StateBridge contract can transfer ownership of StateBridge

```solidity
function test_owner_transferOwnership_succeeds(address newOwner) public;
```

**Parameters**

| Name       | Type      | Description                                              |
| ---------- | --------- | -------------------------------------------------------- |
| `newOwner` | `address` | The new owner of the StateBridge contract (foundry fuzz) |

### test_owner_transferOwnershipOptimism_succeeds

tests whether the StateBridge contract can transfer ownership of the OPWorldID contract

```solidity
function test_owner_transferOwnershipOptimism_succeeds(address newOwner, bool isLocal) public;
```

**Parameters**

| Name       | Type      | Description                                                                                    |
| ---------- | --------- | ---------------------------------------------------------------------------------------------- |
| `newOwner` | `address` | The new owner of the OPWorldID contract (foundry fuzz)                                         |
| `isLocal`  | `bool`    | Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract |

### test_sendRootMultichain_reverts

tests that a root that is not is not a valid root in WorldID Identity Manager contract can't be sent to the StateBridge

```solidity
function test_sendRootMultichain_reverts(uint256 newRoot, address notWorldID) public;
```

### test_notOwner_transferOwnership_reverts

tests that the StateBridge contract's ownership can't be changed by a non-owner

```solidity
function test_notOwner_transferOwnership_reverts(address nonOwner, address newOwner) public;
```

**Parameters**

| Name       | Type      | Description                                              |
| ---------- | --------- | -------------------------------------------------------- |
| `nonOwner` | `address` |                                                          |
| `newOwner` | `address` | The new owner of the StateBridge contract (foundry fuzz) |

### test_notOwner_transferOwnershipOptimism_reverts

tests that the StateBridge contract's ownership can't be changed by a non-owner

```solidity
function test_notOwner_transferOwnershipOptimism_reverts(
    address nonOwner,
    address newOwner,
    bool isLocal
) public;
```

**Parameters**

| Name       | Type      | Description                                              |
| ---------- | --------- | -------------------------------------------------------- |
| `nonOwner` | `address` |                                                          |
| `newOwner` | `address` | The new owner of the StateBridge contract (foundry fuzz) |
| `isLocal`  | `bool`    |                                                          |

## Events

### OwnershipTransferred

OpenZeppelin Ownable.sol transferOwnership event

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

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

### invalidCrossDomainMessengerFork

emitted if there is no CrossDomainMessenger contract deployed on the fork

```solidity
error invalidCrossDomainMessengerFork();
```

### NotWorldIDIdentityManager

```solidity
error NotWorldIDIdentityManager();
```
