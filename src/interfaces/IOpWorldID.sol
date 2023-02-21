//SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

/// @title Interface for the OpWorldID contract
interface IOpWorldID {
    /// @notice receiveRoot is called by the L1 Proxy contract which forwards new Semaphore roots to L2.
    /// @param newRoot new valid root with ROOT_HISTORY_EXPIRY validity
    /// @param timestamp Ethereum block timestamp of the new Semaphore root
    function receiveRoot(uint256 newRoot, uint128 timestamp) external;
}
