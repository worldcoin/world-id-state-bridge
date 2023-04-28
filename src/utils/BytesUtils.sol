pragma solidity ^0.8.15;

library BytesUtils {
    /// @notice Thrown when the payload is too short to contain a selector (at least 4 bytes).
    error PayloadTooShort();

    /// @notice grabSelector, takes a byte array _payload as input and returns the first 4 bytes
    /// of the array as a bytes4 value _selector. The function uses EVM assembly language
    /// to load the 4-byte selector from the _payload array and then shift it left by 224 bits
    /// (0xE0 in hexadecimal) to get the correct value.
    /// @param _payload The byte array from which to extract the selector
    /// @return _selector The first 4 bytes of the _payload array (the function selector from encodeWithSignature)
    function grabSelector(bytes memory _payload) internal pure returns (bytes4 _selector) {
        if (_payload.length < 4) {
            revert PayloadTooShort();
        }
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
    function stripSelector(bytes memory _payload) internal pure returns (bytes memory _payloadData) {
        if (_payload.length <= 4) {
            revert PayloadTooShort();
        }
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
            for {
                let i := 0x00
            } lt(i, mload(_payload)) {
                i := add(i, 0x20)
            } {
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

    /// @custom:fnauthor ENS
    /// @custom:source https://github.com/ensdomains/ens-contracts/blob/09f44a985c901bf86a1c6d00f78c51086d7b9afd/contracts/dnssec-oracle/BytesUtils.sol#L294-L318
    /// @dev Copies a substring into a new byte string.
    /// @param self The byte string to copy from.
    /// @param offset The offset to start copying at.
    /// @param len The number of bytes to copy.
    function substring(bytes memory self, uint256 offset, uint256 len) internal pure returns (bytes memory) {
        require(offset + len <= self.length);

        bytes memory ret = new bytes(len);
        uint256 dest;
        uint256 src;

        assembly {
            dest := add(ret, 32)
            src := add(add(self, 32), offset)
        }
        memcpy(dest, src, len);

        return ret;
    }

    /// @custom:fnauthor ENS
    /// @custom:source https://github.com/ensdomains/ens-contracts/blob/09f44a985c901bf86a1c6d00f78c51086d7b9afd/contracts/dnssec-oracle/BytesUtils.sol#LL273C4-L292C6
    function memcpy(uint256 dest, uint256 src, uint256 len) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        unchecked {
            uint256 mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}
