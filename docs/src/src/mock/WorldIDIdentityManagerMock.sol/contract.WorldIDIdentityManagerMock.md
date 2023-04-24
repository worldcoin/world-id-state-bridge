# WorldIDIdentityManagerMock

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/mock/WorldIDIdentityManagerMock.sol)

**Inherits:** Initializable

**Author:** Worldcoin

Mock of the WorldID Identity Manager contract (world-id-contracts) to test functionality on a local chain

_deployed through make mock and make local-mock_

## State Variables

### stateBridge

```solidity
address public stateBridge;
```

### rootHistory

```solidity
mapping(uint256 => bool) public rootHistory;
```

## Functions

### initialize

```solidity
function initialize(address _stateBridge) public virtual;
```

### sendRootToStateBridge

```solidity
function sendRootToStateBridge(uint256 root) public;
```

### checkValidRoot

```solidity
function checkValidRoot(uint256) public pure returns (bool);
```
