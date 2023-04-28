// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { IWorldIDIdentityManager } from "../interfaces/IWorldIDIdentityManager.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BytesUtils } from "src/utils/BytesUtils.sol";

/// @title Polygon WorldID Bridge Mock
/// @author Worldcoin
/// @dev of the Polygon FxPortal Bridge to test low-level assembly functions
/// `grabSelector` and `stripSelector` in the PolygonWorldID contract
contract MockPolygonBridge is Ownable {
    /// @notice mock rootHistory
    mapping(uint256 => uint128) public rootHistory;

    /// @notice mock rootHistoryExpiry
    uint256 public rootHistoryExpiry = 1 hours;

    /// @notice The selector of the `receiveRoot` function.
    /// @dev this selector is precomputed in the constructor to not have to recompute them for every
    /// call of the _processMesageFromRoot function
    bytes4 private receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    /// @dev this selector is precomputed in the constructor to not have to recompute them for every
    /// call of the _processMesageFromRoot function
    bytes4 private receiveRootHistoryExpirySelector;

    /// @notice Thrown when root history expiry is set
    event RootHistoryExpirySet(uint256 rootHistoryExpiry);

    /// @notice Thrown when new root is inserted
    event ReceivedRoot(uint256 root, uint128 supersedeTimestamp);

    /// @notice Thrown when the message selector passed from FxRoot is invalid.
    error InvalidMessageSelector(bytes4 selector);

    /// @notice constructor
    constructor() {
        receiveRootSelector = bytes4(keccak256("receiveRoot(uint256,uint128)"));
        receiveRootHistoryExpirySelector = bytes4(keccak256("setRootHistoryExpiry(uint256)"));
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

        if (selector == receiveRootSelector) {
            (uint256 root, uint128 timestamp) = abi.decode(payload, (uint256, uint128));
            receiveRoot(root, timestamp);
        } else if (selector == receiveRootHistoryExpirySelector) {
            uint256 newRootHistoryExpiry = abi.decode(payload, (uint256));
            setRootHistoryExpiry(newRootHistoryExpiry);
        } else {
            revert InvalidMessageSelector(selector);
        }
    }

    /// @notice Updates the WorldID root history with a new root.
    /// @param newRoot The new root to add to the root history.
    /// @param supersedeTimestamp The timestamp at which the new root supersedes the current root.
    /// @dev This function is called by the StateBridge contract.
    function receiveRoot(uint256 newRoot, uint128 supersedeTimestamp) internal {
        rootHistory[newRoot] = supersedeTimestamp;

        emit ReceivedRoot(newRoot, supersedeTimestamp);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the `rootHistoryExpiry` variable to the provided value.
    /// @param newRootHistoryExpiry The new value for `rootHistoryExpiry`.
    /// @dev This function is called by the StateBridge contract.
    function setRootHistoryExpiry(uint256 newRootHistoryExpiry) internal {
        rootHistoryExpiry = newRootHistoryExpiry;

        emit RootHistoryExpirySet(newRootHistoryExpiry);
    }
}
