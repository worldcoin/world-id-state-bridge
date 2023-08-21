//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the OpWorldID contract
/// @author Worldcoin
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
    ///
    /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
    /// @custom:reverts string If the caller is not the owner.
    function receiveRoot(uint256 newRoot) external;
}
