//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for WorldID setRooHistoryExpiry
/// @author Worldcoin
/// @notice Interface for WorldID setRooHistoryExpiry
/// @dev Used in StateBridge to set the root history expiry time on Optimism (OPWorldID)
/// @custom:usage abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_expiryTime));
interface IRootHistory {
    /// @notice Sets the amount of time it takes for a root in the root history to expire.
    ///
    /// @param expiryTime The new amount of time it takes for a root to expire.
    ///
    /// @custom:reverts string If the caller is not the owner.
    function setRootHistoryExpiry(uint256 expiryTime) external;
}
