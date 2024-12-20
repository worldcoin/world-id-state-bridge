//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title Interface for the GnosisWorldID contract
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @custom:usage abi.encodeCall(IGnosisWorldID.receiveRoot, (_newRoot));
interface IGnosisWorldID {
    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// @param newRoot The value of the new root.
    function receiveRoot(uint256 newRoot) external;
}
