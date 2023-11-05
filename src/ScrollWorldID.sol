// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {WorldIDBridge} from "./abstract/WorldIDBridge.sol";

import {IScrollWorldID} from "./interfaces/IScrollWorldID.sol";
import {ScrollCrossDomainOwnable} from "src/ScrollCrossDomainOwnable.sol";

/// @title Scroll World ID Bridge
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on
///         Scroll.
/// @dev This contract is deployed on Optimism and is called by the L1 Proxy contract for each new
///      root insertion.
contract ScrollWorldID is WorldIDBridge, ScrollCrossDomainOwnable, IScrollWorldID {
    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract the depth of the associated merkle tree.
    ///
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    constructor(uint8 _treeDepth) WorldIDBridge(_treeDepth) {}

    ///////////////////////////////////////////////////////////////////////////////
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
    function receiveRoot(uint256 newRoot) external virtual onlyOwner {
        _receiveRoot(newRoot);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the amount of time it takes for a root in the root history to expire.
    ///
    /// @param expiryTime The new amount of time it takes for a root to expire.
    ///
    /// @custom:reverts string If the caller is not the owner.
    function setRootHistoryExpiry(uint256 expiryTime) public virtual override onlyOwner {
        _setRootHistoryExpiry(expiryTime);
    }
}
