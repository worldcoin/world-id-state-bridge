# DeployStateBridge

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/script/deploy/DeployStateBridgeGoerli.s.sol)

**Inherits:** Script

## State Variables

### bridge

```solidity
StateBridge public bridge;
```

### opWorldIDAddress

```solidity
address public opWorldIDAddress;
```

### polygonWorldIDAddress

```solidity
address public polygonWorldIDAddress;
```

### worldIDIdentityManagerAddress

```solidity
address public worldIDIdentityManagerAddress;
```

### crossDomainMessengerAddress

```solidity
address public crossDomainMessengerAddress;
```

### stateBridgeAddress

```solidity
address public stateBridgeAddress;
```

### checkpointManagerAddress

```solidity
address public checkpointManagerAddress;
```

### fxRootAddress

```solidity
address public fxRootAddress;
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

### privateKey

```solidity
uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
```

## Functions

### setUp

```solidity
function setUp() public;
```

### run

```solidity
function run() public;
```
