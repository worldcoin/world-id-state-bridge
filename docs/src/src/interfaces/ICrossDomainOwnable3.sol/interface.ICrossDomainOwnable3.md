# ICrossDomainOwnable3

[Git Source](https://github.com/worldcoin/world-id-state-bridge/blob/5310dfa83169d2ad2a0eac7fa77c5c40fc5823d0/src/interfaces/ICrossDomainOwnable3.sol)

**Author:** Worldcoin

Interface for the CrossDomainOwnable contract for the Optimism L2

_Adds functionality to the StateBridge to transfer ownership of OpWorldID to another contract on L1 or to a local
Optimism EOA_

## Functions

### transferOwnership

transfers owner to a cross-domain or local owner

```solidity
function transferOwnership(address _owner, bool _isLocal) external;
```

**Parameters**

| Name       | Type      | Description                                                           |
| ---------- | --------- | --------------------------------------------------------------------- |
| `_owner`   | `address` | new owner (EOA or contract)                                           |
| `_isLocal` | `bool`    | true if new owner is on Optimism, false if it is a cross-domain owner |
