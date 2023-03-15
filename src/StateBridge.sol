// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Optimism interface for cross domain messaging
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {IBridge} from "./interfaces/IBridge.sol";
import {IOpWorldID} from "./interfaces/IOpWorldID.sol";
import {ICrossDomainOwnable3} from "./interfaces/ICrossDomainOwnable3.sol";
import {WorldIDIdentityManagerImplV1} from "./mock/WorldIDIdentityManagerImplV1.sol";
import {FxBaseRootTunnel} from "fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

contract StateBridge is IBridge, FxBaseRootTunnel {
    /// @notice The owner of the contract
    address public owner;

    /// @notice The address of the OPWorldID contract on Optimism
    address public opWorldIDAddress;

    /// @notice The address of the PolygonWorldID contract on Polygon
    address public polygonWorldIDAddress;

    /// @notice address for Optimism's Ethereum mainnet Messenger contract
    address internal crossDomainMessengerAddress;

    /// @notice Interface for checkValidRoot within the WorldID Identity Manager contract
    address public worldIDAddress;

    WorldIDIdentityManagerImplV1 internal worldID;

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice Emmited when the sender is not the owner of the contract
    error Unauthorized();

    /// @notice Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    /// @notice constructor
    /// @param _checkpointManager address of the checkpoint manager contract
    /// @param _fxRoot address of the fxRoot contract (Goerli or Mainnet)
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _opWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// @param _polygonWorldIDAddress Address of the Polygon PoS contract that will receive the new root and timestamps
    /// @param _crossDomainMessenger Deployment of the CrossDomainMessenger contract
    constructor(
        address _checkpointManager,
        address _fxRoot,
        address _worldIDIdentityManager,
        address _opWorldIDAddress,
        address _polygonWorldIDAddress,
        address _crossDomainMessenger
    ) FxBaseRootTunnel(_checkpointManager, _fxRoot) {
        owner = msg.sender;
        opWorldIDAddress = _opWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        crossDomainMessengerAddress = _crossDomainMessenger;
        worldID = WorldIDIdentityManagerImplV1(_worldIDIdentityManager);
    }

    /// @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    function sendRootMultichain(uint256 root) public {
        // If the root is not a valid root in the canonical WorldID Identity Manager contract, revert
        // comment out for mock deployments

        if (!worldID.checkValidRoot(root)) revert InvalidRoot();

        uint128 timestamp = uint128(block.timestamp);
        _sendRootToOptimism(root, timestamp);
        _sendRootToPolygon(root, timestamp);
        // add other chains here
    }

    /*//////////////////////////////////////////////////////////////
                                OPTIMISM
    //////////////////////////////////////////////////////////////*/

    // @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    function _sendRootToOptimism(uint256 root, uint128 timestamp) internal {
        bytes memory message;

        message = abi.encodeCall(IOpWorldID.receiveRoot, (root, timestamp));

        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            1000000
        );
    }

    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of OpWorldID to another contract on L1 or to a local Optimism EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwership(address _owner, bool _isLocal) external onlyOwner {
        bytes memory message;

        message = abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));

        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            1000000
        );
    }

    /*//////////////////////////////////////////////////////////////
                                POLYGON
    //////////////////////////////////////////////////////////////*/

    /// @notice Send message to Polygon's StateChild contract
    /// @param message bytes to send to Polygon
    function sendMessageToChild(bytes memory message) public {
        _sendMessageToChild(message);
    }

    /// @notice Sends root and timestamp to Polygon's StateChild contract (PolygonWorldID)
    /// @param root The latest WorldID Identity Manager root to be sent to Polygon
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root
    function _sendRootToPolygon(uint256 root, uint128 timestamp) internal {
        bytes memory message;

        message = abi.encode(root, timestamp);

        _sendMessageToChild(message);
    }

    /// @notice boilerplate function to satisfy the FxBaseRootTunnel interface (not going to be used)
    function _processMessageFromChild(bytes memory message) internal virtual override {}
}
