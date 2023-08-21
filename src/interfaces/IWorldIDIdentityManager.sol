// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title IWorldIDIdentityManager
/// @author Worldcoin
/// @dev used to fetch the latest root from the WorldIDIdentityManager
interface IWorldIDIdentityManager {
    /// @notice returns the latest root
    function latestRoot() external view returns (uint256);
}
