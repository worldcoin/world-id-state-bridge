# ISendBridge

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/interfaces/ISendBridge.sol)

**Author:** Worldcoin

An interface for contracts that can send roots to state bridge from World ID Identity Manager

## Functions

### sendRootToStateBridge

A function that sends a root to the state bridge.

```solidity
function sendRootToStateBridge(uint256 root) external;
```

**Parameters**

| Name   | Type      | Description             |
| ------ | --------- | ----------------------- |
| `root` | `uint256` | The root value to send. |
