    // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Optimism interface for cross domain messaging
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {IMessageProxy} from "ima-interfaces/IMessageProxy.sol";
import {IOpWorldID} from "./interfaces/IOpWorldID.sol";
import {IPolygonWorldID} from "./interfaces/IPolygonWorldID.sol";
import {ISKLALEWorldID} from "./interfaces/ISKLALEWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import {ICrossDomainOwnable3} from "./interfaces/ICrossDomainOwnable3.sol";

/// @title World ID State Bridge
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to World ID supported networks
/// @dev This contract lives on Ethereum mainnet and is called by the World ID Identity Manager contract
/// in the registerIdentities method
contract StateBridge is Ownable2Step {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the OPWorldID contract on Optimism
    // address public immutable opWorldIDAddress;

    /// @notice The address of the chaosWorldIDAddress contract on Optimism
    address public SKALEWorldIDAddress;

    address public immutable SKALE_IMAAddress_mainnet;

    /// @notice address for Optimism's Ethereum mainnet L1CrossDomainMessenger contract
    //address internal immutable crossDomainMessengerAddress;

    /// @notice worldID Address
    address public immutable worldIDAddress;

    /// @notice Amount of gas purchased on Optimism for _sendRootToOptimism
    //uint32 internal opGasLimitSendRootOptimism;

    /// @notice Amount of gas purchased on Optimism for setRootHistoryExpiryOptimism
    // uint32 internal opGasLimitSetRootHistoryExpiryOptimism;

    /// @notice Amount of gas purchased on Optimism for transferOwnershipOptimism
    /// uint32 internal opGasLimitTransferOwnershipOptimism;

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

    // /// @notice Emmitted when the the StateBridge sets the opGasLimit for sendRootOptimism
    // /// @param _opGasLimit The new opGasLimit for sendRootOptimism
    // event SetOpGasLimitSendRootOptimism(uint32 _opGasLimit);

    // /// @notice Emmitted when the the StateBridge sets the opGasLimit for setRootHistoryExpiryOptimism
    // /// @param _opGasLimit The new opGasLimit for setRootHistoryExpiryOptimism
    // event SetOpGasLimitSetRootHistoryExpiryOptimism(uint32 _opGasLimit);

    // /// @notice Emmitted when the the StateBridge sets the opGasLimit for transferOwnershipOptimism
    // /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    // event SetOpGasLimitTransferOwnershipOptimism(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Thrown when the caller of `sendRootMultichain` is not the WorldID Identity Manager contract.
    error NotWorldIDIdentityManager();

    /// @notice Thrown when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

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

    constructor(
        // address _checkpointManager,
        //address _fxRoot,
        address _worldIDIdentityManager,
        //address _opWorldIDAddress,
        //address _crossDomainMessenger,
        address _SKALEWorldIDAddress,
        address _SKALE_IMAAddress_mainnet
    ) {
        //opWorldIDAddress = _opWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        SKALEWorldIDAddress = _SKALEWorldIDAddress;
        SKALE_IMAAddress_mainnet = _SKALE_IMAAddress_mainnet;
        //crossDomainMessengerAddress = _crossDomainMessenger;
        //opGasLimitSendRootOptimism = 100000;
        //opGasLimitSetRootHistoryExpiryOptimism = 100000;
        //opGasLimitTransferOwnershipOptimism = 100000;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    function AuxSetSkaleWorldIdAddress(address _skaleWorldIDAddress) public {
        SKALEWorldIDAddress = _skaleWorldIDAddress;
    }

    function sendRootMultichain(uint256 root) external onlyWorldIDIdentityManager {
        uint128 timestamp = uint128(block.timestamp);
        // _sendRootToOptimism(root, timestamp);
        // _sendRootToPolygon(root, timestamp);
        _sendRootToSKALE(root, timestamp);
        // add other chains here

        emit RootSentMultichain(root, timestamp);
    }

    function setRootHistoryExpiry(uint256 expiryTime) public onlyWorldIDIdentityManager {
        //setRootHistoryExpiryOptimism(expiryTime);
        //setRootHistoryExpiryPolygon(expiryTime);
        setRootHistoryExpirySKALE(expiryTime);

        emit SetRootHistoryExpiry(expiryTime);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           SKALE - CHAOS                     ///
    ///////////////////////////////////////////////////////////////////

    function _sendRootToSKALE(uint256 root, uint128 timestamp) internal {
       // string memory chainName = "staging-fast-active-bellatrix";
        // ISKLALEWorldID.receiveRoot -> function receiveRoot(uint256 newRoot, uint128 supersedeTimestamp) external;
        bytes memory receiveRoot_data = abi.encodeCall(ISKLALEWorldID.receiveRoot, (root, timestamp));

        // bytes memory message = abi.encodeCall(SKLALEWorldID.postMessage, this.address, receiveRoot_data));

        IMessageProxy(SKALE_IMAAddress_mainnet).postOutgoingMessage(bytes32(keccak256("staging-fast-active-bellatrix")), SKALEWorldIDAddress, receiveRoot_data);
    }

    function setRootHistoryExpirySKALE(uint256 _rootHistoryExpiry) internal {
        //string memory chainName = "staging-fast-active-bellatrix";
        // IRootHistory.setRootHistoryExpiry -> function setRootHistoryExpiry(uint256 expiryTime) external;
        bytes memory setRootHistoryExpiry_data =
            abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));
        // bytes memory message = abi.encodeCall(SKLALEWorldID.postMessage, (bytes32(keccak256(chainName)),this.address,setRootHistoryExpiry_data));

        IMessageProxy(SKALE_IMAAddress_mainnet).postOutgoingMessage(bytes32(keccak256("staging-fast-active-bellatrix")), SKALEWorldIDAddress, setRootHistoryExpiry_data);
    }

    // ///////////////////////////////////////////////////////////////////
    // ///                           OPTIMISM                          ///
    // ///////////////////////////////////////////////////////////////////

    // /// @notice Sends the latest WorldID Identity Manager root to all chains.
    // /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    // /// @param root The latest WorldID Identity Manager root.
    // /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    // function _sendRootToOptimism(uint256 root, uint128 timestamp) internal {
    //     // The `encodeCall` function is strongly typed, so this checks that we are passing the
    //     // correct data to the optimism bridge.
    //     bytes memory message = abi.encodeCall(IOpWorldID.receiveRoot, (root, timestamp));

    //     ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
    //         // Contract address on Optimism
    //         opWorldIDAddress,
    //         message,
    //         opGasLimitSendRootOptimism
    //     );
    // }

    // /// @notice Adds functionality to the StateBridge to transfer ownership
    // /// of OpWorldID to another contract on L1 or to a local Optimism EOA
    // /// @param _owner new owner (EOA or contract)
    // /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    // function transferOwnershipOptimism(address _owner, bool _isLocal) public onlyOwner {
    //     bytes memory message;

    //     // The `encodeCall` function is strongly typed, so this checks that we are passing the
    //     // correct data to the optimism bridge.
    //     message = abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));

    //     ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
    //         // Contract address on Optimism
    //         opWorldIDAddress,
    //         message,
    //         opGasLimitTransferOwnershipOptimism
    //     );

    //     emit OwnershipTransferredOptimism(owner(), _owner, _isLocal);
    // }

    // /// @notice Adds functionality to the StateBridge to set the root history expiry on OpWorldID
    // /// @param _rootHistoryExpiry new root history expiry
    // function setRootHistoryExpiryOptimism(uint256 _rootHistoryExpiry) internal {
    //     bytes memory message;

    //     // The `encodeCall` function is strongly typed, so this checks that we are passing the
    //     // correct data to the optimism bridge.
    //     message = abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

    //     ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
    //         // Contract address on Optimism
    //         opWorldIDAddress,
    //         message,
    //         opGasLimitSetRootHistoryExpiryOptimism
    //     );
    // }

    // ///////////////////////////////////////////////////////////////////
    // ///                         OP GAS LIMIT                        ///
    // ///////////////////////////////////////////////////////////////////

    // /// @notice Sets the gas limit for the Optimism sendRootMultichain method
    // /// @param _opGasLimit The new gas limit for the sendRootMultichain method
    // function setOpGasLimitSendRootOptimism(uint32 _opGasLimit) external onlyOwner {
    //     opGasLimitSendRootOptimism = _opGasLimit;

    //     emit SetOpGasLimitSendRootOptimism(_opGasLimit);
    // }

    // /// @notice Sets the gas limit for the Optimism setRootHistoryExpiry method
    // /// @param _opGasLimit The new gas limit for the setRootHistoryExpiry method
    // function setOpGasLimitSetRootHistoryExpiryOptimism(uint32 _opGasLimit) external onlyOwner {
    //     opGasLimitSetRootHistoryExpiryOptimism = _opGasLimit;

    //     emit SetOpGasLimitSetRootHistoryExpiryOptimism(_opGasLimit);
    // }

    // /// @notice Sets the gas limit for the transferOwnershipOptimism method
    // /// @param _opGasLimit The new gas limit for the transferOwnershipOptimism method
    // function setOpGasLimitTransferOwnershipOptimism(uint32 _opGasLimit) external onlyOwner {
    //     opGasLimitTransferOwnershipOptimism = _opGasLimit;

    //     emit SetOpGasLimitTransferOwnershipOptimism(_opGasLimit);
    // }

    // ///////////////////////////////////////////////////////////////////
    // ///                           POLYGON                           ///
    // ///////////////////////////////////////////////////////////////////

    // /// @notice Sends root and timestamp to Polygon's StateChild contract (PolygonWorldID)
    // /// @param root The latest WorldID Identity Manager root to be sent to Polygon
    // /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root
    // function _sendRootToPolygon(uint256 root, uint128 timestamp) internal {
    //     bytes memory message;

    //     message = abi.encodeCall(IPolygonWorldID.receiveRoot, (root, timestamp));

    //     /// @notice FxBaseRootTunnel method to send bytes payload to FxBaseChildTunnel contract
    //     _sendMessageToChild(message);
    // }

    // /// @notice Sets the root history expiry for PolygonWorldID
    // /// @param _rootHistoryExpiry The new root history expiry
    // function setRootHistoryExpiryPolygon(uint256 _rootHistoryExpiry) internal {
    //     bytes memory message;

    //     message = abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

    //     /// @notice FxBaseRootTunnel method to send bytes payload to FxBaseChildTunnel contract
    //     _sendMessageToChild(message);
    // }

    // /// @notice boilerplate function to satisfy FxBaseRootTunnel inheritance (not going to be used)
    // function _processMessageFromChild(bytes memory) internal override {
    //     /// WorldID 🌎🆔 State Bridge
    // }

    // ///////////////////////////////////////////////////////////////////////////////
    // ///                            ADDRESS MANAGEMENT                           ///
    // ///////////////////////////////////////////////////////////////////////////////

    // /// @notice Sets the `fxChildTunnel` address if not already set.
    // /// @dev This implementation replicates the logic from `FxBaseRootTunnel` due to the inability
    // ///      to call `external` superclass methods when overriding them.
    // ///
    // /// @param _fxChildTunnel The address of the child (non-L1) tunnel contract.
    // ///
    // /// @custom:reverts string If the root tunnel has already been set.
    // function setFxChildTunnel(address _fxChildTunnel) public virtual override onlyOwner {
    //     require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
    //     fxChildTunnel = _fxChildTunnel;
    // }

    // ///////////////////////////////////////////////////////////////////
    // ///                          OWNERSHIP                          ///
    // ///////////////////////////////////////////////////////////////////
    // /// @notice Ensures that ownership of WorldID implementations cannot be renounced.
    // /// @dev This function is intentionally not `virtual` as we do not want it to be possible to
    // ///      renounce ownership for any WorldID implementation.
    // /// @dev This function is marked as `onlyOwner` to maintain the access restriction from the base
    // ///      contract.
    // function renounceOwnership() public view override onlyOwner {
    //     revert CannotRenounceOwnership();
    // }
}
