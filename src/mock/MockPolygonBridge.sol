// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

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
    bytes4 receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    bytes4 receiveRootHistoryExpirySelector;

    /// @title FxPortal Mock
    /// @author Worldcoin
    /// @notice

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

    /// @notice grabSelector, takes a byte array _payload as input and returns the first 4 bytes
    /// of the array as a bytes4 value _selector. The function uses EVM assembly language
    /// to load the 4-byte selector from the _payload array and then shift it left by 224 bits
    /// (0xE0 in hexadecimal) to get the correct value.
    /// @param _payload The byte array from which to extract the selector
    /// @return _selector The first 4 bytes of the _payload array (the function selector from encodeWithSignature)
    function grabSelector(bytes memory _payload) internal pure returns (bytes4 _selector) {
        assembly ("memory-safe") {
            /// @dev uses mload to load the first 32 bytes of _payload
            /// (starting at memory address _payload + 0x20) into memory,
            /// then shr to shift the loaded value right by 224 bits
            /// (0xE0 in hexadecimal). Therefore only the last 4 bytes (32 bits remain),
            /// and finally we pad the value to the left by using shl to shift
            /// the by 224 bits to the left to get the correct value for _selector.
            _selector := shl(0xE0, shr(0xE0, mload(add(_payload, 0x20))))
        }
    }

    /// @notice  stripSelector, takes a byte array _payload as input and returns a new byte array
    /// _payloadData that contains all the data in _payload except for the first 4 bytes (the selector).
    /// The function first allocates a new block of memory to store the new byte array, then copies the
    /// length of the original _payload array (minus 4 bytes) into the new array, and then copies the
    /// remaining data from the original _payload array into the new array, starting from the fifth byte.
    /// The function then updates the free memory pointer to account for the new memory allocation.
    /// @param _payload The byte array from which to extract the payload data
    /// @return _payloadData The payload data from the _payload array
    /// (payload minus selector which is 4 bytes long)
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
            /// @dev These lines copy the length of the original _payload array
            /// (minus 4 bytes for the selector) into the first 32 bytes of the new
            /// _payloadData array. Specifically, it uses mload to load the value stored
            /// at memory address _payload, which is the length of the _payload array,
            /// and then sub to subtract 4 from this value to get the correct length for
            /// _payloadData. Finally, it uses mstore to store this value at memory address _payloadData.
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

            // Compute the last 32-byte aligned memory address of the copied data
            let lastAlignedAddr := add(dataStart, and(newLength, not(0x1F)))

            // Compute the number of bytes beyond the end of the copied data
            let endBytes := sub(newLength, sub(lastAlignedAddr, dataStart))

            // Load the last 32-byte word of the copied data
            let lastWord := mload(lastAlignedAddr)

            // Zero out any erroneously copied bits beyond the end of the payload data
            let mask := sub(shl(endBytes, 0x8), 0x1)
            lastWord := and(lastWord, not(mask))

            // Store the modified word back to memory
            mstore(lastAlignedAddr, lastWord)
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
