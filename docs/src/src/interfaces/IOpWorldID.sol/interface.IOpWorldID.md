# IOpWorldID

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/interfaces/IOpWorldID.sol)

**Author:** Worldcoin

Interface for the CrossDomainOwnable contract for the Optimism L2

_Adds functionality to the StateBridge to transfer ownership of OpWorldID to another contract on L1 or to a local
Optimism EOA_

## Functions

### receiveRoot

receiveRoot is called by the L1 Proxy contract which forwards new Semaphore roots to L2.

```solidity
function receiveRoot(uint256 newRoot, uint128 timestamp) external;
```

**Parameters**

| Name        | Type      | Description                                        |
| ----------- | --------- | -------------------------------------------------- |
| `newRoot`   | `uint256` | new valid root with ROOT_HISTORY_EXPIRY validity   |
| `timestamp` | `uint128` | Ethereum block timestamp of the new Semaphore root |
