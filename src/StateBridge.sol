// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Optimism interface for cross domain messaging
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {IBridge} from "./interfaces/IBridge.sol";
import {IOpWorldID} from "./interfaces/IOpWorldID.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {ICrossDomainOwnable3} from "./interfaces/ICrossDomainOwnable3.sol";
import {FxBaseRootTunnel} from "fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

contract StateBridge is IBridge, FxBaseRootTunnel, Ownable {
    /// @notice The address of the OPWorldID contract on Optimism
    address public opWorldIDAddress;

    /// @notice address for Optimism's Ethereum mainnet Messenger contract
    address internal crossDomainMessengerAddress;

    /// @notice Interface for checkValidRoot within the WorldID Identity Manager contract
    address public worldIDAddress;

    IWorldIDIdentityManager internal worldID;

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice constructor
    /// @param _checkpointManager address of the checkpoint manager contract
    /// @param _fxRoot address of the fxRoot contract (Goerli or Mainnet)
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _opWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// @param _crossDomainMessenger Deployment of the CrossDomainMessenger contract
    constructor(
        address _checkpointManager,
        address _fxRoot,
        address _worldIDIdentityManager,
        address _opWorldIDAddress,
        address _crossDomainMessenger
    ) FxBaseRootTunnel(_checkpointManager, _fxRoot) {
        opWorldIDAddress = _opWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        worldID = IWorldIDIdentityManager(_worldIDIdentityManager);
        crossDomainMessengerAddress = _crossDomainMessenger;
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
