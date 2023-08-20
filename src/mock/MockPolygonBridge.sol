// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {WorldIDBridge} from "../abstract/WorldIDBridge.sol";
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BytesUtils} from "src/utils/BytesUtils.sol";

/// @title Polygon WorldID Bridge Mock
/// @author Worldcoin
/// @dev of the Polygon FxPortal Bridge to test low-level assembly functions
/// `grabSelector` and `stripSelector` in the PolygonWorldID contract
contract MockPolygonBridge is WorldIDBridge, Ownable {
    /// @notice The selector of the `receiveRoot` function.
    /// @dev this selector is precomputed in the constructor to not have to recompute them for every
    /// call of the _processMesageFromRoot function
    bytes4 internal _receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    /// @dev this selector is precomputed in the constructor to not have to recompute them for every
    /// call of the _processMesageFromRoot function
    bytes4 internal _receiveRootHistoryExpirySelector;

    /// @notice Emitted when the message selector passed from FxRoot is invalid.
    error InvalidMessageSelector(bytes4 selector);

    /// @notice Initializes the contract's storage variables with the correct parameters
    ///
    /// @param _treeDepth The depth of the WorldID Identity Manager merkle tree.
    constructor(uint8 _treeDepth) WorldIDBridge(_treeDepth) {
        _receiveRootSelector = bytes4(keccak256("receiveRoot(uint256)"));
        _receiveRootHistoryExpirySelector = bytes4(keccak256("setRootHistoryExpiry(uint256)"));
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Mock for Polygon's FxPortal bridge functionality
    ///
    /// @param message An ABI-encoded tuple of `(uint256 newRoot, uint128 supersedeTimestamp)` that
    ///        is used to call `receiveRoot`.
    function processMessageFromRoot(bytes memory message) public onlyOwner {
        // I need to decode selector and payload here
        bytes4 selector = bytes4(BytesUtils.substring(message, 0, 4));
        bytes memory payload = BytesUtils.substring(message, 4, message.length - 4);

        if (selector == _receiveRootSelector) {
            uint256 root = abi.decode(payload, (uint256));
            _receiveRoot(root);
        } else if (selector == _receiveRootHistoryExpirySelector) {
            uint256 newRootHistoryExpiry = abi.decode(payload, (uint256));
            _setRootHistoryExpiry(newRootHistoryExpiry);
        } else {
            revert InvalidMessageSelector(selector);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Placeholder to satisfy WorldIDBridge inheritance
    /// @dev This function is not used on Polygon PoS because of FxPortal message passing architecture
    function setRootHistoryExpiry(uint256) public virtual override {
        revert("PolygonWorldID: Root history expiry should only be set via the state bridge");
    }
}
