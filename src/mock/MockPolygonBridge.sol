// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Optimism interface for cross domain messaging
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "forge-std/console.sol";

/// @title Mock Polygon Bridge Functionality
/// @author Worldcoin
/// @notice Mock of the StateBridge to test functionality on a local chain
/// @custom:deployment deployed through make local-mock
contract MockPolygonBridge is Ownable {
    /// @notice mock rootHistory
    mapping(uint256 => uint128) public rootHistory;

    /// @notice mock rootHistoryExpiry
    uint256 public rootHistoryExpiry = 1 hours;

    /// @notice The selector of the `receiveRoot` function.
    bytes4 receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    bytes4 receiveRootHistoryExpirySelector;

    /// @notice Thrown when root history expiry is set
    event RootHistoryExpirySet(uint256 rootHistoryExpiry);

    /// @notice Thrown when new root is inserted
    event ReceivedRoot(uint256 root, uint128 supersedeTimestamp);

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice Thrown when the message selector passed from FxRoot is invalid.
    error InvalidMessageSelector();

    /// @notice constructor
    constructor() {
        receiveRootSelector = bytes4(keccak256("receiveRoot(uint256,uint128)"));
        receiveRootHistoryExpirySelector = bytes4(keccak256("setRootHistoryExpiry(uint256)"));
    }

    function grabSelector(bytes memory _payload) internal pure returns (bytes4 _selector) {
        assembly ("memory-safe") {
            _selector := shl(0xE0, shr(0xE0, mload(add(_payload, 0x20))))
        }
    }

    function stripSelector(bytes memory _payload)
        internal
        pure
        returns (bytes memory _payloadData)
    {
        assembly ("memory-safe") {
            // Grab the pointer to some free memory
            _payloadData := mload(0x40)

            // Copy the length - 4
            let newLength := sub(mload(_payload), 0x04)
            mstore(_payloadData, newLength)

            // Copy the data following the selector
            let dataStart := add(_payloadData, 0x20)
            let payloadStart := add(_payload, 0x24)
            for { let i := 0x00 } lt(i, mload(_payload)) { i := add(i, 0x20) } {
                mstore(add(dataStart, i), mload(add(payloadStart, i)))
            }

            // Account for the full length of the copied data
            // length word + data length
            let fullLength := add(newLength, 0x20)

            // Update the free memory pointer
            mstore(0x40, add(_payloadData, and(add(fullLength, 0x1F), not(0x1F))))

            // TODO: Probably also want to clean any erroniously copied bits in the
            //       last word of the payload for full safety.
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Mock for Polygon's FxPortal bridge functionality
    ///
    /// @param message An ABI-encoded tuple of `(uint256 newRoot, uint128 supersedeTimestamp)` that
    ///        is used to call `receiveRoot`.
    function processMessageFromRoot(bytes calldata message) public onlyOwner {
        // I need to decode selector and payload here
        bytes4 selector = grabSelector(message);
        bytes memory payload = stripSelector(message);
        console.logBytes4(selector);
        console.logBytes4(receiveRootSelector);
        console.logBytes4(receiveRootHistoryExpirySelector);

        if (selector == receiveRootSelector) {
            (uint256 root, uint128 timestamp) = abi.decode(payload, (uint256, uint128));
            receiveRoot(root, timestamp);
        } else if (selector == receiveRootHistoryExpirySelector) {
            uint256 newRootHistoryExpiry = abi.decode(payload, (uint256));
            setRootHistoryExpiry(newRootHistoryExpiry);
        } else {
            revert InvalidMessageSelector();
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
