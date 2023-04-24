# TransferOwnershipOfOpWorldIDGoerli

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/script/initialize/TransferOwnershipOfOpWorldIDGoerli.s.sol)

**Inherits:** Script

Initializes the StateBridge contract

## State Variables

### stateBridgeAddress

```solidity
address public stateBridgeAddress;
```

### opWorldIDAddress

```solidity
address public opWorldIDAddress;
```

### crossDomainMessengerAddress

```solidity
address public immutable crossDomainMessengerAddress;
```

### privateKey

```solidity
uint256 public privateKey;
```

### opWorldID

```solidity
OpWorldID public opWorldID;
```

### isLocal

in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle for local or cross domain
(using the CrossDomainMessenger to pass messages)

```solidity
bool public isLocal;
```

## Functions

### setUp

```solidity
function setUp() public;
```

### constructor

```solidity
constructor();
```

### run

```solidity
function run() public;
```

### transferOwnershipToStateBridge

cross domain ownership flag false = cross domain (address on Ethereum) true = local (address on Optimism)

```solidity
function transferOwnershipToStateBridge(address newOwner, bool _isLocal) internal;
```
