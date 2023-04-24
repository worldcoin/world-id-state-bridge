# DeployOpWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/script/deploy/DeployOpWorldID.s.sol)

**Inherits:** Script

## State Variables

### opWorldID

```solidity
OpWorldID public opWorldID;
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

### treeDepth

```solidity
uint8 public treeDepth = abi.decode(vm.parseJson(json, ".treeDepth"), (uint8));
```

## Functions

### run

```solidity
function run() external;
```
