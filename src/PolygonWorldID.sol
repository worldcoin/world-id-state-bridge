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
    /// @notice The selector of the `receiveRoot` function.
    bytes4 receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    bytes4 receiveRootHistoryExpirySelector;

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Thrown when calling setRootHistoryExpiry which is a placeholder function.
    error SetRootHistoryExpiryPlaceholder();

    /// @notice Thrown when the message selector passed from FxRoot is invalid.
    error InvalidMessageSelector(bytes4 selector);

    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract's storage variables with the correct parameters
    ///
    /// @param _treeDepth The depth of the WorldID Identity Manager merkle tree.
    /// @param _fxChild The address of the FxChild tunnel - the contract that will receive messages on Polygon
    /// and Broadcasts them to FxPortal which bridges the messages to Ethereum
    constructor(uint8 _treeDepth, address _fxChild)
        WorldIDBridge(_treeDepth)
        FxBaseChildTunnel(_fxChild)
    {
        receiveRootSelector = bytes4(keccak256("receiveRoot(bytes)"));
        receiveRootHistoryExpirySelector = bytes4(keccak256("receiveRootHistoryExpiry(bytes)"));
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice An internal function used to receive messages from the StateBridge contract.
    /// @dev Calls `receiveRoot` upon receiving a message from the StateBridge contract via the
    ///      FxChildTunnel. Can revert if the message is not valid - decoding fails.
    ///      Can not work if Polygon's StateSync mechanism breaks and FxPortal does not receive the message
    ///      on the other end.
    ///
    /// @custom:param uint256 stateId An unused placeholder variable for `stateId`,
    /// required by the signature in fxChild.
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
        bytes4 selector = abi.decode(message, (bytes4));

        if (selector == receiveRootSelector || selector == receiveRootHistoryExpirySelector) {
            address(this).call(message);
        } else {
            revert InvalidMessageSelector(selector);
        }
    }

    /// @notice Updates the WorldID root history with a new root.
    /// @param message An ABI-encoded tuple of `(uint256 newRoot, uint128 supersedeTimestamp)`
    /// @dev This function is called by the StateBridge contract.
    function receiveRoot(bytes memory message) internal {
        // This decodes as specified in the parameter block. If this fails, it will revert.
        (uint256 newRoot, uint128 timestamp) = abi.decode(message, (uint256, uint128));

        _receiveRoot(newRoot, timestamp);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the `rootHistoryExpiry` variable to the provided value.
    /// @param message An ABI-encoded tuple of `(uint256 expiryTime)`
    /// @dev This function is called by the StateBridge contract.
    function receiveRootHistoryExpiry(bytes memory message) internal {
        uint256 expiryTime = abi.decode(message, (uint256));

        _setRootHistoryExpiry(expiryTime);
    }

    /// @notice Placeholder to satisfy WorldIDBridge inheritance
    /// @dev This function is not used on Polygon PoS because of FxPortal message passing architecture
    function setRootHistoryExpiry(uint256) public virtual override {
        revert SetRootHistoryExpiryPlaceholder();
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                             TUNNEL MANAGEMENT                           ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the `fxRootTunnel` address if not already set.
    /// @dev This implementation replicates the logic from `FxBaseChildTunnel` due to the inability
    ///      to call `external` superclass methods when overriding them.
    ///
    /// @param _fxRootTunnel The address of the root (L1) tunnel contract.
    ///
    /// @custom:reverts string If the root tunnel has already been set.
    function setFxRootTunnel(address _fxRootTunnel) external virtual override onlyOwner {
        require(fxRootTunnel == address(0x0), "FxBaseChildTunnel: ROOT_TUNNEL_ALREADY_SET");
        fxRootTunnel = _fxRootTunnel;
    }
}
