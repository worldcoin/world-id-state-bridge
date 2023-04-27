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
    error InvalidMessageSelector();

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
        bytes4 selector = grabSelector(message);
        bytes memory payload = stripSelector(message);

        if (selector == receiveRootSelector) {
            (uint256 root, uint128 timestamp) = abi.decode(payload, (uint256, uint128));
            _receiveRoot(root, timestamp);
        } else if (selector == receiveRootHistoryExpirySelector) {
            uint256 rootHistoryExpiry = abi.decode(payload, (uint256));
            _setRootHistoryExpiry(rootHistoryExpiry);
        } else {
            revert InvalidMessageSelector();
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

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
