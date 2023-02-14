// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import {Verifier as SemaphoreVerifier} from "semaphore/contracts/base/Verifier.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {FxBaseChildTunnel} from "fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

/// @title PolygonWorldID
/// @author Worldcoin
/// @notice A contract that manages the root history of the WorldID merkle root on Polygon PoS.
/// @dev This contract is deployed on Polygon PoS and is called by the StateBridge contract for new root insertions.
contract PolygonWorldID is IWorldID, FxBaseChildTunnel, Initializable {
    /// @notice latest data received from Ethereum mainnet
    bytes public latestData;

    /// @notice The address of the StateBridge contract on Ethereum mainnet
    address internal _stateBridgeAddress;

    /// @notice The amount of time a root is considered as valid on Polygon.
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

    /// @notice Thrown when attempting to send messages from a contract that is not the StateBridge contract.
    error SenderIsNotStateBridge();

    constructor(address _fxChild) FxBaseChildTunnel(_fxChild) {
        _disableInitializers();
    }

    function initialize(uint256 preRoot, uint128 preRootTimestamp, address stateBridgeAddress)
        public
        virtual
        initializer
    {
        _stateBridgeAddress = stateBridgeAddress;
        rootHistory[preRoot] = preRootTimestamp;
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
        uint256[4] memory publicSignals = [root, nullifierHash, signalHash, externalNullifierHash];

        if (checkValidRoot(root)) {
            semaphoreVerifier.verifyProof(
                [proof[0], proof[1]], [[proof[2], proof[3]], [proof[4], proof[5]]], [proof[6], proof[7]], publicSignals
            );
        }
    }

    /*//////////////////////////////////////////////////////////////
                              STATE BRIDGE
    //////////////////////////////////////////////////////////////*/

    /// @notice receiveRoot is called by the StateBridge contract which forwards new WorldID roots to Polygon.
    /// @param data newRoot and timestamp encoded as bytes
    function receiveRoot(bytes memory data) external {
        (newRoot, timestamp) = abi.decode(data, (uint256, uint128));

        rootHistory[newRoot] = timestamp;

        emit RootAdded(newRoot, timestamp);
    }

    /// @notice internal function used to receive messages from the StateBridge contract
    /// @dev calls receiveRoot upon receiving a message from the StateBridge contract
    /// @param stateId the stateId of the message
    /// @param sender of the message
    /// @param data newRoot and timestamp encoded as bytes
    function _processMessageFromRoot(uint256 stateId, address sender, bytes memory data)
        internal
        override
        validateSender(sender)
    {
        if (sender != _stateBridgeAddress) revert SenderIsNotStateBridge();

        latestData = data;

        receiveRoot(data);
    }
}