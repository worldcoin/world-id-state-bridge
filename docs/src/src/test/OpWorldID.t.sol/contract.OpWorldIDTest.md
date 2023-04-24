# OpWorldIDTest

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/test/OpWorldID.t.sol)

**Inherits:** Messenger_Initializer

**Author:** Worldcoin

A test contract for OpWorldID

_using Test from forge-std which is inherited from Optimism's CommonTest.t.sol_

_The OpWorldID contract is deployed on Optimism and is called by the StateBridge contract._

_This contract uses the Optimism CommonTest.t.sol testing tool suite._

## State Variables

### id

The OpWorldID contract

```solidity
OpWorldID internal id;
```

### treeDepth

MarkleTree depth

```solidity
uint8 internal treeDepth = 16;
```

## Functions

### testConstructorWithInvalidTreeDepth

```solidity
function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public;
```

### setUp

```solidity
function setUp() public override;
```

### \_switchToCrossDomainOwnership

CrossDomainOwnable3 setup

Initialize the OpWorldID contract

_label important addresses_

```solidity
function _switchToCrossDomainOwnership(OpWorldID _id) internal;
```

### test_onlyOwner_notMessenger_reverts

Test that when \_isLocal = false, a contract that is not the L2 Messenger can't call the contract

```solidity
function test_onlyOwner_notMessenger_reverts(uint256 newRoot) external;
```

**Parameters**

| Name      | Type      | Description                                        |
| --------- | --------- | -------------------------------------------------- |
| `newRoot` | `uint256` | The root of the merkle tree after the first update |

### test_onlyOwner_notOwner_reverts

Test that a non-owner can't insert a new root

```solidity
function test_onlyOwner_notOwner_reverts(uint256 newRoot) external;
```

**Parameters**

| Name      | Type      | Description                                        |
| --------- | --------- | -------------------------------------------------- |
| `newRoot` | `uint256` | The root of the merkle tree after the first update |

### test_receiveVerifyRoot_succeeds

Test that you can insert new root and check if it is valid

```solidity
function test_receiveVerifyRoot_succeeds(uint256 newRoot) public;
```

**Parameters**

| Name      | Type      | Description                                        |
| --------- | --------- | -------------------------------------------------- |
| `newRoot` | `uint256` | The root of the merkle tree after the first update |

### test_receiveVerifyInvalidRoot_reverts

Test that a root that hasn't been inserted is invalid

```solidity
function test_receiveVerifyInvalidRoot_reverts(uint256 newRoot) public;
```

**Parameters**

| Name      | Type      | Description                                        |
| --------- | --------- | -------------------------------------------------- |
| `newRoot` | `uint256` | The root of the merkle tree after the first update |

### test_expiredRoot_reverts

Test that you can insert a root and check it has expired if more than 7 days have passed

```solidity
function test_expiredRoot_reverts(uint256 newRoot, uint256 secondRoot) public;
```

**Parameters**

| Name         | Type      | Description                                                         |
| ------------ | --------- | ------------------------------------------------------------------- |
| `newRoot`    | `uint256` | The root of the merkle tree after the first update (forge fuzzing)  |
| `secondRoot` | `uint256` | The root of the merkle tree after the second update (forge fuzzing) |

### testCanGetTreeDepth

Checks that it is possible to get the tree depth the contract was initialized with.

```solidity
function testCanGetTreeDepth(uint8 actualTreeDepth) public;
```

## Events

### OwnershipTransferred

OpenZeppelin Ownable.sol transferOwnership event

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```

### OwnershipTransferred

CrossDomainOwnable3.sol transferOwnership event

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, bool isLocal);
```
