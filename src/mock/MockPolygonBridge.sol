// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Optimism interface for cross domain messaging
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
    error InvalidMessageSelector(bytes4 selector);

    /// @notice constructor
    constructor() {
        receiveRootSelector = bytes4(keccak256("receiveRoot(bytes)"));
        receiveRootHistoryExpirySelector = bytes4(keccak256("receiveRootHistoryExpiry(bytes)"));
    }

    ///////////////////////////////////////////////////////////////////
    ///                            UTILS                            ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Loads the first word of the encoded data and cleans the upper 224 bits
    /// (leaving only the 4 byte selector)
    /// @param _payload The encoded data (_payload = abi.encodeWithSignature("fnName(type)", arg1))
    ///
    /// @return _selector The selector of the function called in the encoded data
    function grabSelector(bytes memory _payload) internal pure returns (bytes4 _selector) {
        assembly ("memory-safe") {
            _selector := shl(0xE0, shr(0xE0, mload(add(_payload, 0x20))))
        }
    }

    /// @notice Extracts the payload from an abi.encodeWithSignature object
    /// @param _payload The encoded data (_payload = abi.encodeWithSignature("fnName(type)", arg1))
    ///
    /// @return _payloadData The payload (abi.encoded params) of the encoded data
    function grabParams(bytes memory _payload) internal pure returns (bytes memory _payloadData) {
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
    function processMessageFromRoot(bytes memory message) public onlyOwner {
        // I need to decode selector and payload here
        bytes4 selector = grabSelector(message);
        bytes memory payload = grabParams(message);

        if (selector == receiveRootSelector) {
            receiveRoot(payload);
        } else if (selector == receiveRootHistoryExpirySelector) {
            setRootHistoryExpiry(payload);
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

        rootHistory[newRoot] = timestamp;

        emit ReceivedRoot(newRoot, timestamp);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the `rootHistoryExpiry` variable to the provided value.
    /// @param message An ABI-encoded tuple of `(uint256 expiryTime)`
    /// @dev This function is called by the StateBridge contract.
    function setRootHistoryExpiry(bytes memory message) internal {
        uint256 expiryTime = abi.decode(message, (uint256));

        rootHistoryExpiry = expiryTime;

        emit RootHistoryExpirySet(expiryTime);
    }
}
