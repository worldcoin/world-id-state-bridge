// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {SemaphoreTreeDepthValidator} from "./utils/SemaphoreTreeDepthValidator.sol";
import {SemaphoreVerifier} from "semaphore/base/SemaphoreVerifier.sol";

/// @title OpWorldID
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on Optimism.
/// @dev This contract is deployed on Optimism and is called by the L1 Proxy contract for new root insertions.
contract MockOpPolygonWorldID {
    /// @notice The depth of the Semaphore merkle tree.
    uint8 internal treeDepth = 16;

    /// @notice The amount of time a root is considered as valid on Optimism.
    uint256 internal constant ROOT_HISTORY_EXPIRY = 1 weeks;

    /// @notice A mapping from the value of the merkle tree root to the timestamp at which it was submitted
    mapping(uint256 => uint128) public rootHistory;

    /// @notice The verifier instance needed for operating within the semaphore protocol.
    SemaphoreVerifier private semaphoreVerifier = new SemaphoreVerifier();

    /// @notice Emitted when a new root is inserted into the root history.
    event RootAdded(uint256 root, uint128 timestamp);

    /// @notice Thrown when attempting to validate a root that has expired.
    error ExpiredRoot();

    /// @notice Thrown when attempting to validate a root that has yet to be added to the root
    ///         history.
    error NonExistentRoot();

    /// @notice receiveRoot is called by the state bridge contract which forwards new WorldID roots to Optimism.
    /// @param newRoot new valid root with ROOT_HISTORY_EXPIRY validity
    /// @param timestamp Ethereum block timestamp of the new Semaphore root
    function receiveRoot(uint256 newRoot, uint128 timestamp) external {
        // when running locally on Anvil, block.timestamp will always be 0, so we hardcode 100
        rootHistory[newRoot] = 100;

        emit RootAdded(newRoot, timestamp);
    }

    /// @notice Checks if a given root value is valid and has been added to the root history.
    /// @dev Reverts with `ExpiredRoot` if the root has expired, and `NonExistentRoot` if the root
    ///      is not in the root history.
    /// @param root The root of a given identity group.
    function checkValidRoot(uint256 root) public view returns (bool) {
        uint128 rootTimestamp = rootHistory[root];

        // A root does not exist if it has no associated timestamp.
        if (rootTimestamp == 0) {
            revert NonExistentRoot();
        }

        return true;
    }

    /// A verifier for the semaphore protocol.
    ///
    /// @notice Reverts if the zero-knowledge proof is invalid.
    /// @dev Note that a double-signaling check is not included here, and should be carried by the
    ///      caller.
    /// @param root The of the Merkle tree
    /// @param signalHash A keccak256 hash of the Semaphore signal
    /// @param nullifierHash The nullifier hash
    /// @param externalNullifierHash A keccak256 hash of the external nullifier
    /// @param proof The zero-knowledge proof
    function verifyProof(
        uint256 root,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256 externalNullifierHash,
        uint256[8] calldata proof
    ) public view {
        if (checkValidRoot(root)) {
            semaphoreVerifier.verifyProof(
                root, nullifierHash, signalHash, externalNullifierHash, proof, treeDepth
            );
        }
    }

    /// @notice Gets the Semaphore tree depth the contract was initialized with.
    ///
    /// @return initializedTreeDepth Tree depth.
    function getTreeDepth() public view virtual returns (uint8 initializedTreeDepth) {
        return treeDepth;
    }
}
