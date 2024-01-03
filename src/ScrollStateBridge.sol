// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IScrollWorldID} from "./interfaces/IScrollWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import {IScrollCrossDomainOwnable} from "./interfaces/IScrollCrossDomainOwnable.sol";

// Scroll interface for cross domain messaging
import {IScrollMessenger} from "@scroll-tech/contracts/libraries/IScrollMessenger.sol";

/// @title World ID State Bridge Scroll
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to Scroll
contract ScrollStateBridge is Ownable2Step {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the ScrollWorldID contract
    address public immutable scrollWorldIDAddress;

    /// @notice address for the Scroll Messenger contract on Ethereum
    address internal immutable scrollMessengerAddress;

    /// @notice Ethereum World ID Identity Manager Address
    address public immutable worldIDAddress;

    /// @notice Amount of gas purchased on Scroll for propagateRoot
    uint32 internal _gasLimitPropagateRoot;

    /// @notice Amount of gas purchased on Scroll for SetRootHistoryExpiry
    uint32 internal _gasLimitSetRootHistoryExpiry;

    /// @notice Amount of gas purchased on Scroll for transferOwnershipScroll
    uint32 internal _gasLimitTransferOwnership;

    /// @notice The default gas limit amount to buy on Scroll
    uint32 public constant DEFAULT_SCROLL_GAS_LIMIT = 1000000;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the StateBridge gives ownership of the ScrollWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the ScrollWorldID contract
    /// @param newOwner The new owner of the ScrollWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Scroll)
    /// or an Ethereum EOA or contract
    event OwnershipTransferredScroll(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Emitted when the StateBridge sends a root to the ScrollWorldID contract
    /// @param root The root sent to the ScrollWorldID contract on Scroll
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for ScrollWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the StateBridge sets the gas limit for sendRootScroll
    /// @param _scrollGasLimit The new scrollGasLimit for sendRootScroll
    event SetGasLimitPropagateRoot(uint32 _scrollGasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for SetRootHistoryExpiry
    /// @param _scrollGasLimit The new scrollGasLimit for SetRootHistoryExpiry
    event SetGasLimitSetRootHistoryExpiry(uint32 _scrollGasLimit);

    /// @notice Emitted when the StateBridge sets the gas limit for transferOwnershipScroll
    /// @param _scrollGasLimit The new scrollGasLimit for transferOwnershipScroll
    event SetGasLimitTransferOwnershipScroll(uint32 _scrollGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

    /// @notice Emitted when an attempt is made to set the gas limit to zero
    error GasLimitZero();

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _scrollWorldIDAddress Address of the Scroll contract that will receive the new root and timestamp
    /// @param _scrollMessengerAddress Scroll Messenger address on Ethereum
    /// @custom:revert if any of the constructor params addresses are zero
    constructor(
        address _worldIDIdentityManager,
        address _scrollWorldIDAddress,
        address _scrollMessengerAddress
    ) {
        if (
            _worldIDIdentityManager == address(0) || _scrollWorldIDAddress == address(0)
                || _scrollMessengerAddress == address(0)
        ) {
            revert AddressZero();
        }

        scrollWorldIDAddress = _scrollWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        scrollMessengerAddress = _scrollMessengerAddress;
        _gasLimitPropagateRoot = DEFAULT_SCROLL_GAS_LIMIT;
        _gasLimitSetRootHistoryExpiry = DEFAULT_SCROLL_GAS_LIMIT;
        _gasLimitTransferOwnership = DEFAULT_SCROLL_GAS_LIMIT;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to Scroll
    /// @dev Calls this method on the L1 Proxy contract to relay roots to Scroll
    function propagateRoot() external {
        uint256 latestRoot = IWorldIDIdentityManager(worldIDAddress).latestRoot();

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the Scroll messenger
        bytes memory message = abi.encodeCall(IScrollWorldID.receiveRoot, (latestRoot));

        IScrollMessenger(scrollMessengerAddress).sendMessage(
            // World ID contract address on Scroll
            scrollWorldIDAddress,
            //value
            0,
            message,
            // gas limit
            _gasLimitPropagateRoot,
            // refund address
            msg.sender
        );

        emit RootPropagated(latestRoot);
    }

    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of ScrollWorldID to another contract on L1 or to a local Scroll EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Scroll, false if it is a cross-domain owner
    /// @custom:revert if _owner is set to the zero address
    function transferOwnershipScroll(address _owner, bool _isLocal) external onlyOwner {
        if (_owner == address(0)) {
            revert AddressZero();
        }

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the Scroll Messenger.
        bytes memory message =
            abi.encodeCall(IScrollCrossDomainOwnable.transferOwnership, (_owner, _isLocal));

        IScrollMessenger(scrollMessengerAddress).sendMessage(
            // World ID contract address on Scroll
            scrollWorldIDAddress,
            //value
            0,
            message,
            // gas limit
            _gasLimitTransferOwnership,
            // refund address
            msg.sender
        );

        emit OwnershipTransferredScroll(owner(), _owner, _isLocal);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on ScrollWorldID
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external onlyOwner {
        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the Scroll bridge.
        bytes memory message =
            abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

        IScrollMessenger(scrollMessengerAddress).sendMessage(
            // World ID contract address on Scroll
            scrollWorldIDAddress,
            //value
            0,
            message,
            // gas limit
            _gasLimitSetRootHistoryExpiry,
            // refund address
            msg.sender
        );

        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                       SCROLL GAS LIMIT                      ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sets the gas limit for the propagateRoot method
    /// @param _scrollGasLimit The new gas limit for the propagateRoot method
    function setGasLimitPropagateRoot(uint32 _scrollGasLimit) external onlyOwner {
        if (_scrollGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitPropagateRoot = _scrollGasLimit;

        emit SetGasLimitPropagateRoot(_scrollGasLimit);
    }

    /// @notice Sets the gas limit for the SetRootHistoryExpiry method
    /// @param _scrollGasLimit The new gas limit for the SetRootHistoryExpiry method
    function setGasLimitSetRootHistoryExpiry(uint32 _scrollGasLimit) external onlyOwner {
        if (_scrollGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitSetRootHistoryExpiry = _scrollGasLimit;

        emit SetGasLimitSetRootHistoryExpiry(_scrollGasLimit);
    }

    /// @notice Sets the gas limit for the transferOwnershipScroll method
    /// @param _scrollGasLimit The new gas limit for the transferOwnershipScroll method
    function setGasLimitTransferOwnershipScroll(uint32 _scrollGasLimit) external onlyOwner {
        if (_scrollGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitTransferOwnership = _scrollGasLimit;

        emit SetGasLimitTransferOwnershipScroll(_scrollGasLimit);
    }

    ///////////////////////////////////////////////////////////////////
    ///                          OWNERSHIP                          ///
    ///////////////////////////////////////////////////////////////////
    /// @notice Ensures that ownership of WorldID implementations cannot be renounced.
    /// @dev This function is intentionally not `virtual` as we do not want it to be possible to
    ///      renounce ownership for any WorldID implementation.
    /// @dev This function is marked as `onlyOwner` to maintain the access restriction from the base
    ///      contract.
    function renounceOwnership() public view override onlyOwner {
        revert CannotRenounceOwnership();
    }
}
