//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the ScrollWorldID contract
/// @author Worldcoin
/// @custom:usage abi.encodeCall(IScrollWorldID.receiveRoot, (_newRoot, _supersedeTimestamp));
interface IScrollWorldID {
    ////////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// @dev    This function can revert if Scroll's ScrollMessenger stops processing proofs
    ///
    /// @param newRoot The value of the new root.
    ///
    /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
    /// @custom:reverts string If the caller is not the owner.
    function receiveRoot(uint256 newRoot) external;
}
