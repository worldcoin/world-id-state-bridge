// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

/// @title ISemaphoreRoot
/// @author Worldcoin
/// @dev used to check if a root is valid for the StateBridge
interface IWorldIDIdentityManager {
    /// @notice Checks if a given root value is valid and has been added to the root history.
    /// @dev Reverts with `ExpiredRoot` if the root has expired, and `NonExistentRoot` if the root
    ///      is not in the root history.
    ///
    /// @param root The root of a given identity group.
    function checkValidRoot(uint256 root) external view returns (bool);
}
