// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

/// @title Semaphore tree depth validator
/// @author Worldcoin
library SemaphoreTreeDepthValidator {
    /// @notice Checks if the provided `treeDepth` is among supported depths.
    ///
    /// @param treeDepth The tree depth to validate.
    /// @return supportedDepth Returns `true` if `treeDepth` is between 16 and 32
    function validate(uint8 treeDepth) internal pure returns (bool supportedDepth) {
        uint8 minDepth = 16;
        uint8 maxDepth = 32;
        return treeDepth >= minDepth && treeDepth <= maxDepth;
    }
}
