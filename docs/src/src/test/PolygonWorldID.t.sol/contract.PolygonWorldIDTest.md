# PolygonWorldIDTest

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/test/PolygonWorldID.t.sol)

**Inherits:** PRBTest, StdCheats

**Author:** Worldcoin

A test contract for PolygonWorldID

_The PolygonWorldID contract is deployed on Polygon PoS and is called by the StateBridge contract._

_This contract uses the Optimism CommonTest.t.sol tool suite to test the PolygonWorldID contract._

## State Variables

### id

The PolygonWorldID contract

```solidity
PolygonWorldID internal id;
```

### treeDepth

MarkleTree depth

```solidity
uint8 internal treeDepth = 16;
```

### newRoot

The root of the merkle tree after the first update

```solidity
uint256 public newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;
```

### newRootTimestamp

The timestamp of the root of the merkle tree after the first update

```solidity
uint128 public newRootTimestamp;
```

### alice

demo address

```solidity
address public alice = address(0x1111111);
```

### fxChild

fxChild contract address

```solidity
address public fxChild = address(0x2222222);
```

### data

```solidity
bytes public data;
```

## Functions

### testConstructorWithInvalidTreeDepth

```solidity
function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public;
```

### setUp

```solidity
function setUp() public;
```

### testCanGetTreeDepth

Initialize the PolygonWorldID contract

Checks that it is possible to get the tree depth the contract was initialized with.

_label important addresses_

```solidity
function testCanGetTreeDepth(uint8 actualTreeDepth) public;
```
