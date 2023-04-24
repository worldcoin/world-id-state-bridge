# InitializePolygonWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/script/initialize/InitializePolygonWorldID.s.sol)

**Inherits:** Script

## State Variables

### stateBridgeAddress

```solidity
address public stateBridgeAddress;
```

### polygonWorldIDAddress

```solidity
address public polygonWorldIDAddress;
```

### fxChildAddress

```solidity
address public fxChildAddress = address(0xCf73231F28B7331BBe3124B907840A94851f9f11);
```

### polygonWorldID

```solidity
PolygonWorldID public polygonWorldID;
```

### privateKey

```solidity
uint256 public privateKey;
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
