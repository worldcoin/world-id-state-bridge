//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the PolygonWorldID contract
/// @author Worldcoin
/// @notice Interface for the CrossDomainOwnable contract for the Optimism L2
/// @custom:usage abi.encodeCall(IPolygonWorldID.receiveRoot, (_newRoot, _supersedeTimestamp));
interface IPolygonWorldID {
    ////////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    ///
    /// @param newRoot The value of the new root.
    /// @param supersedeTimestamp The value of the L1 timestamp at the time that `newRoot` became
    ///        the current root. This timestamp is associated with the latest root at the time of
    ///        the call being inserted into the root history.
    ///
    /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
    /// @custom:reverts string If the caller is not the owner.
    function receiveRoot(uint256 newRoot, uint128 supersedeTimestamp) external;
}
