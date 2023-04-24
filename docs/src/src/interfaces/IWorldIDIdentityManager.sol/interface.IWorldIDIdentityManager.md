# IWorldIDIdentityManager

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/interfaces/IWorldIDIdentityManager.sol)

**Author:** Worldcoin

_used to check if a root is valid for the StateBridge_

## Functions

### checkValidRoot

Checks if a given root value is valid and has been added to the root history.

_Reverts with `ExpiredRoot` if the root has expired, and `NonExistentRoot` if the root is not in the root history._

```solidity
function checkValidRoot(uint256 root) external view returns (bool);
```

**Parameters**

| Name   | Type      | Description                         |
| ------ | --------- | ----------------------------------- |
| `root` | `uint256` | The root of a given identity group. |
