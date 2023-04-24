# SemaphoreTreeDepthValidator

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/utils/SemaphoreTreeDepthValidator.sol)

**Author:** Worldcoin

## Functions

### validate

Checks if the provided `treeDepth` is among supported depths.

```solidity
function validate(uint8 treeDepth) internal pure returns (bool supportedDepth);
```

**Parameters**

| Name        | Type    | Description                 |
| ----------- | ------- | --------------------------- |
| `treeDepth` | `uint8` | The tree depth to validate. |

**Returns**

| Name             | Type   | Description                                        |
| ---------------- | ------ | -------------------------------------------------- |
| `supportedDepth` | `bool` | Returns `true` if `treeDepth` is between 16 and 32 |
