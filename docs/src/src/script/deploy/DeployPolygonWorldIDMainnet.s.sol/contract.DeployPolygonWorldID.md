# DeployPolygonWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/script/deploy/DeployPolygonWorldIDMainnet.s.sol)

**Inherits:** Script

## State Variables

### stateBridgeAddress

```solidity
address public stateBridgeAddress;
```

### fxChildAddress

```solidity
address fxChildAddress = address(0x8397259c983751DAf40400790063935a11afa28a);
```

### polygonWorldId

```solidity
PolygonWorldID public polygonWorldId;
```

### privateKey

```solidity
uint256 public privateKey;
```

### treeDepth

```solidity
uint8 public treeDepth;
```

### root

```solidity
string public root = vm.projectRoot();
```

### path

```solidity
string public path = string.concat(root, "/script/.deploy-config.json");
```

### json

```solidity
string public json = vm.readFile(path);
```

## Functions

### setUp

```solidity
function setUp() public;
```

### run

```solidity
function run() external;
```
