//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the OpWorldID contract
/// @author Worldcoin
/// @notice Interface for the CrossDomainOwnable contract for the Optimism L2
/// @dev Adds functionality to the StateBridge to transfer ownership
/// of OpWorldID to another contract on L1 or to a local Optimism EOA
/// @custom:usage abi.encodeCall(IOpWorldID.receiveRoot, (_newRoot, _supersedeTimestamp));
interface IOpWorldID {
    ////////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// @dev    This function can revert if Optimism's CrossDomainMessenger stops processing proofs
    ///         or if OPLabs stops submitting them. Next iteration of Optimism's cross-domain messaging, will be
    ///         fully permissionless for message-passing, so this will not be an issue.
    ///         Sequencer needs to include changes to the CrossDomainMessenger contract on L1, not economically penalized
    ///         if messages are not included, however the fraud prover (Cannon) can force the sequencer to include it.
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
