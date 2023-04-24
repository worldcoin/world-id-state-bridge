# IBridge

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/interfaces/IBridge.sol)

**Author:** Worldcoin

contains the interface for the State Bridge contract to send a root to World ID supported networks

## Functions

### sendRootMultichain

Sends the latest Semaphore root to all chains.

_Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains._

```solidity
function sendRootMultichain(uint256 root) external;
```

**Parameters**

| Name   | Type      | Description                |
| ------ | --------- | -------------------------- |
| `root` | `uint256` | The latest Semaphore root. |
