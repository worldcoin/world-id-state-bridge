// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {WorldIDBridge} from "./abstract/WorldIDBridge.sol";

import {FxBaseChildTunnel} from "fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {SemaphoreTreeDepthValidator} from "./utils/SemaphoreTreeDepthValidator.sol";
import {SemaphoreVerifier} from "semaphore/base/SemaphoreVerifier.sol";

/// @title Polygon WorldID Bridge
/// @author Worldcoin
/// @notice A contract that manages the root history of the WorldID merkle root on Polygon PoS.
/// @dev This contract is deployed on Polygon PoS and is called by the StateBridge contract for each
///      new root insertion.
contract PolygonWorldID is WorldIDBridge, FxBaseChildTunnel, Ownable {
    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract.
    ///
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    /// @param _fxChild The address of the FX child tunnel to use.
    constructor(uint8 _treeDepth, address _fxChild)
        WorldIDBridge(_treeDepth)
        FxBaseChildTunnel(_fxChild)
        Ownable()
    {
        if (!SemaphoreTreeDepthValidator.validate(_treeDepth)) {
            revert UnsupportedTreeDepth(_treeDepth);
        }

        treeDepth = _treeDepth;
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice An internal function used to receive messages from the StateBridge contract.
    /// @dev Calls `receiveRoot` upon receiving a message from the StateBridge contract via the
    ///      FxChildTunnel.
    ///
    /// uint256 stateId An unused placeholder variable for `stateId`, required by the signature in fxChild.
    /// @param sender The sender of the message.
    /// @param message An ABI-encoded tuple of `(uint256 newRoot, uint128 supersedeTimestamp)` that
    ///        is used to call `receiveRoot`.
    ///
    /// @custom:reverts string If the sender is not valid.
    /// @custom:reverts EvmError If the provided `message` does not match the expected format.
    function _processMessageFromRoot(uint256, address sender, bytes memory message)
        internal
        override
        validateSender(sender)
    {
        // This decodes as specified in the parameter block. If this fails, it will revert.
        (uint256 newRoot, uint128 timestamp) = abi.decode(message, (uint256, uint128));

        _receiveRoot(newRoot, timestamp);
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
