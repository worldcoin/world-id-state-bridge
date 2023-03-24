// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {SemaphoreTreeDepthValidator} from "./utils/SemaphoreTreeDepthValidator.sol";
import {SemaphoreVerifier} from "semaphore/base/SemaphoreVerifier.sol";
import {FxBaseChildTunnel} from "fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

/// @title PolygonWorldID
/// @author Worldcoin
/// @notice A contract that manages the root history of the WorldID merkle root on Polygon PoS.
/// @dev This contract is deployed on Polygon PoS and is called by the StateBridge contract for new root insertions.
contract PolygonWorldID is FxBaseChildTunnel {
    /// @notice The depth of the Semaphore merkle tree.
    uint8 internal treeDepth;

    /// @notice FxBaseChildTunnel: The address of the StateBridge contract on Ethereum mainnet
    address internal _stateBridgeAddress;

    /// @notice The amount of time a root is considered as valid on Polygon.
    uint256 internal constant ROOT_HISTORY_EXPIRY = 1 weeks;

    /// @notice A mapping from the value of the merkle tree root to the timestamp at which it was submitted
    mapping(uint256 => uint128) public rootHistory;

    /// @notice The verifier instance needed for operating within the semaphore protocol.
    SemaphoreVerifier private semaphoreVerifier = new SemaphoreVerifier();

    /// @notice Emitted when a new root is inserted into the root history.
    event RootAdded(uint256 root, uint128 timestamp);

    /// @notice Thrown when Semaphore tree depth is not supported.
    ///
    /// @param depth Passed tree depth.
    error UnsupportedTreeDepth(uint8 depth);

    /// @notice Thrown when attempting to validate a root that has expired.
    error ExpiredRoot();

    /// @notice Thrown when attempting to validate a root that has yet to be added to the root
    ///         history.
    error NonExistentRoot();

    /// @notice Thrown when attempting to send messages from a contract that is not the StateBridge contract.
    error SenderIsNotStateBridge();

    /// @notice Connects contract to the Polygon PoS child tunnel.

    /// @notice Initializes the contract with a pre-existing root and timestamp.
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    /// @param _fxChild The address of the Polygon PoS child tunnel.
    /// @param stateBridgeAddress The address of the StateBridge contract on Ethereum mainnet.
    constructor(uint8 _treeDepth, address _fxChild, address stateBridgeAddress)
        FxBaseChildTunnel(_fxChild)
    {
        if (!SemaphoreTreeDepthValidator.validate(_treeDepth)) {
            revert UnsupportedTreeDepth(_treeDepth);
        }

        treeDepth = _treeDepth;
        _stateBridgeAddress = stateBridgeAddress;
    }

    /*//////////////////////////////////////////////////////////////
                                WORLDID
    //////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                              STATE BRIDGE
    //////////////////////////////////////////////////////////////*/

    /// @notice receiveRoot is called by the StateBridge contract which forwards new WorldID roots to Polygon.
    /// @param newRoot The new root of the WorldID merkle tree.
    /// @param timestamp The timestamp at which the root was submitted.
    function receiveRoot(uint256 newRoot, uint128 timestamp) internal {
        rootHistory[newRoot] = timestamp;

        emit RootAdded(newRoot, timestamp);
    }

    /// @notice internal function used to receive messages from the StateBridge contract
    /// @dev calls receiveRoot upon receiving a message from the StateBridge contract
    /// @param stateId of the message (unused)
    /// @param sender of the message
    /// @param message newRoot and timestamp encoded as bytes
    function _processMessageFromRoot(uint256 stateId, address sender, bytes memory message)
        internal
        override
        validateSender(sender)
    {
        (uint256 newRoot, uint128 timestamp) = abi.decode(message, (uint256, uint128));

        receiveRoot(newRoot, timestamp);
    }

    /// @notice Gets the Semaphore tree depth the contract was initialized with.
    ///
    /// @return initializedTreeDepth Tree depth.
    function getTreeDepth() public view virtual returns (uint8 initializedTreeDepth) {
        return treeDepth;
    }
}
