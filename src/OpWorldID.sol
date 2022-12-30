// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// Optimism interface for cross domain messaging
import {
    ICrossDomainMessenger
} from "../node_modules/@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

/// @title L2Root
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on Optimism.
/// @dev This contract is deployed on Optimism and is called by the L1 Proxy contract.
contract OpWorldID {
    /// @notice The amount of time a root is considered as valid on Optimism.
    uint256 internal constant ROOT_HISTORY_EXPIRY = 1 weeks;
    /// @notice A mapping from the value of the merkle tree root to the timestamp at which it was submitted
    mapping(uint256 => uint128) public rootHistory;

    /// @notice Thrown when attempting to validate a root that has expired.
    error ExpiredRoot();

    /// @notice Thrown when attempting to validate a root that has yet to be added to the root
    ///         history.
    error NonExistentRoot();

    constructor(uint256 preRoot, uint128 preRootTimestamp) {
        rootHistory[preRoot] = preRootTimestamp;
    }

    /// @notice receiveRoot is called by the L1 Proxy contract which forwards new Semaphore roots to L2.
    /// @param newRoot new valid root with ROOT_HISTORY_EXPIRY validity
    /// @param timestamp Ethereum block timestamp of the new Semaphore root
    function receiveRoot(uint256 newRoot, uint128 timestamp) external {
        rootHistory[newRoot] = timestamp;
    }

    /// @notice Checks if a given root value is valid and has been added to the root history.
    /// @dev Reverts with `ExpiredRoot` if the root has expired, and `NonExistentRoot` if the root
    ///      is not in the root history.
    /// @param root The root of a given identity group.
    function checkValidRoot(uint256 root) public view returns (bool) {
        uint128 rootTimestamp = rootHistory[root];

        // A root is no longer valid if it has expired.
        if (block.timestamp - rootTimestamp > ROOT_HISTORY_EXPIRY) {
            revert ExpiredRoot();
        }

        // A root does not exist if it has no associated timestamp.
        if (rootTimestamp == 0) {
            revert NonExistentRoot();
        }

        return true;
    }
}
