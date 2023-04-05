//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the OpWorldID contract
/// @author Worldcoin
/// @notice Interface for the CrossDomainOwnable contract for the Optimism L2
/// @dev Adds functionality to the StateBridge to transfer ownership
/// of OpWorldID to another contract on L1 or to a local Optimism EOA
/// @custom:usage abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));
interface IOpWorldID {
    /// @notice receiveRoot is called by the L1 Proxy contract which forwards new Semaphore roots to L2.
    /// @param newRoot new valid root with ROOT_HISTORY_EXPIRY validity
    /// @param timestamp Ethereum block timestamp of the new Semaphore root
    function receiveRoot(uint256 newRoot, uint128 timestamp) external;
}
