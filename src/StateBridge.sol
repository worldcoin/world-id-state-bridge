// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Optimism interface for cross domain messaging
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {IOpWorldID} from "./interfaces/IOpWorldID.sol";
import {IPolygonWorldID} from "./interfaces/IPolygonWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ICrossDomainOwnable3} from "./interfaces/ICrossDomainOwnable3.sol";
import {FxBaseRootTunnel} from "fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

/// @title World ID State Bridge
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to World ID supported networks
/// @dev This contract lives on Ethereum mainnet and is called by the World ID Identity Manager contract
/// in the registerIdentities method
contract StateBridge is FxBaseRootTunnel, Ownable {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the OPWorldID contract on Optimism
    address public opWorldIDAddress;

    /// @notice address for Optimism's Ethereum mainnet L1CrossDomainMessenger contract
    address internal crossDomainMessengerAddress;

    /// @notice worldID Address
    address public worldIDAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOptimism(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Emmitted when the the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emmitted when a root is sent to OpWorldID and PolygonWorldID
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    event RootSentMultichain(uint256 root, uint128 timestamp);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Thrown when the caller of `sendRootMultichain` is not the WorldID Identity Manager contract.
    error NotWorldIDIdentityManager();

    /// @notice Thrown when setWorldIDAddress is called with a zero address
    error CantSetWorldIDAddressToZero();

    ///////////////////////////////////////////////////////////////////
    ///                          MODIFIERS                          ///
    ///////////////////////////////////////////////////////////////////
    modifier onlyWorldIDIdentityManager() {
        if (msg.sender != worldIDAddress) {
            revert NotWorldIDIdentityManager();
        }
        _;
    }

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _checkpointManager address of the checkpoint manager contract
    /// @param _fxRoot address of Polygon's fxRoot contract, part of the FxPortal bridge (Goerli or Mainnet)
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _opWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// @param _crossDomainMessenger L1CrossDomainMessenger contract used to communicate with the Optimism network
    constructor(
        address _checkpointManager,
        address _fxRoot,
        address _worldIDIdentityManager,
        address _opWorldIDAddress,
        address _crossDomainMessenger
    ) FxBaseRootTunnel(_checkpointManager, _fxRoot) {
        opWorldIDAddress = _opWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        crossDomainMessengerAddress = _crossDomainMessenger;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    function sendRootMultichain(uint256 root) external onlyWorldIDIdentityManager {
        uint128 timestamp = uint128(block.timestamp);
        _sendRootToOptimism(root, timestamp);
        _sendRootToPolygon(root, timestamp);
        // add other chains here

        emit RootSentMultichain(root, timestamp);
    }

    /// @notice Sets the root history expiry for OpWorldID (on Optimism) and PolygonWorldID (on Polygon)
    /// @param expiryTime The new root history expiry for OpWorldID and PolygonWorldID
    function setRootHistoryExpiry(uint256 expiryTime) public onlyWorldIDIdentityManager {
        setRootHistoryExpiryOptimism(expiryTime);
        setRootHistoryExpiryPolygon(expiryTime);

        emit SetRootHistoryExpiry(expiryTime);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           OPTIMISM                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    function _sendRootToOptimism(uint256 root, uint128 timestamp) internal {
        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the optimism bridge.
        bytes memory message = abi.encodeCall(IOpWorldID.receiveRoot, (root, timestamp));

        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            200000
        );
    }

    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of OpWorldID to another contract on L1 or to a local Optimism EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwnershipOptimism(address _owner, bool _isLocal) public onlyOwner {
        bytes memory message;

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the optimism bridge.
        message = abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));

        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            200000
        );

        emit OwnershipTransferredOptimism(owner(), _owner, _isLocal);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on OpWorldID
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiryOptimism(uint256 _rootHistoryExpiry) internal {
        bytes memory message;

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the optimism bridge.
        message = abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            200000
        );
    }

    ///////////////////////////////////////////////////////////////////
    ///                           POLYGON                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends root and timestamp to Polygon's StateChild contract (PolygonWorldID)
    /// @param root The latest WorldID Identity Manager root to be sent to Polygon
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root
    function _sendRootToPolygon(uint256 root, uint128 timestamp) internal {
        bytes memory message;

        message = abi.encodeCall(IPolygonWorldID.receiveRoot, (root, timestamp));

        /// @notice FxBaseRootTunnel method to send bytes payload to FxBaseChildTunnel contract
        _sendMessageToChild(message);
    }

    /// @notice Sets the root history expiry for PolygonWorldID
    /// @param _rootHistoryExpiry The new root history expiry
    function setRootHistoryExpiryPolygon(uint256 _rootHistoryExpiry) internal {
        bytes memory message;

        message = abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

        /// @notice FxBaseRootTunnel method to send bytes payload to FxBaseChildTunnel contract
        _sendMessageToChild(message);
    }

    /// @notice boilerplate function to satisfy FxBaseRootTunnel inheritance (not going to be used)
    function _processMessageFromChild(bytes memory) internal override {
        /// WorldID 🌎🆔 State Bridge
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                            ADDRESS MANAGEMENT                           ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the `fxChildTunnel` address if not already set.
    /// @dev This implementation replicates the logic from `FxBaseRootTunnel` due to the inability
    ///      to call `external` superclass methods when overriding them.
    ///
    /// @param _fxChildTunnel The address of the child (non-L1) tunnel contract.
    ///
    /// @custom:reverts string If the root tunnel has already been set.
    function setFxChildTunnel(address _fxChildTunnel) public virtual override onlyOwner {
        require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        fxChildTunnel = _fxChildTunnel;
    }

    /// @notice Sets the WorldIDManagerRouter address
    /// @param _worldIDIdentityManagerAddress The new WorldID Identity Manager Router address
    function setWorldIDIdentityManagerAddress(address _worldIDIdentityManagerAddress)
        public
        onlyOwner
    {
        if (worldIDAddress == address(0x0)) {
            revert CantSetWorldIDAddressToZero();
        }
        worldIDAddress = _worldIDIdentityManagerAddress;
    }
}
