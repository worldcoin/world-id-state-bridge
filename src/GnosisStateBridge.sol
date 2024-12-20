// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {IGnosisWorldID} from "./interfaces/IGnosisWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {IAMB} from "./interfaces/IAMB.sol";

/// @title World ID State Bridge Gnosis
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @notice Distributes new World ID Identity Manager roots to Gnosis
/// @dev This contract lives on Ethereum mainnet and works for Gnosis
contract GnosisStateBridge is Ownable2Step {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the WorldID Identity Manager contract
    address public immutable worldIDIdentityManagerAddress;

    /// @notice The address of the Gnosis contract that will receive the new root and timestamp
    address public immutable gnosisWorldIDAddress;

    /// @notice The address of the Arbitrary Message Bridge contract on the source network
    address public immutable amBridge;

    /// @notice Amount of gas purchased on the Gnosis chain for propagateRoot
    uint32 internal _gasLimitPropagateRoot;

    uint32 public constant DEFAULT_GNOSIS_GAS_LIMIT = 1000000;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the AMB sends a root to the GnosisWorldID contract
    /// @param root The root sent to the GnosisWorldID contract on the Gnosis chain
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for GnosisWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the StateBridge sets the gas limit for sendRootOp
    /// @param _gnosisGasLimit The new gnosisGasLimit for sendRootOp
    event SetGasLimitPropagateRoot(uint32 _gnosisGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    /// @notice Emitted when an attempt is made to set the gas limit to zero
    error GasLimitZero();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _gnosisWorldIDAddress Address of the Gnosis contract that will receive the new root and timestamp
    /// @param _amBridge Address of the Arbitrary Message Bridge contract on the source network
    constructor(address _worldIDIdentityManager, address _gnosisWorldIDAddress, address _amBridge) {
        if (
            _worldIDIdentityManager == address(0) || _gnosisWorldIDAddress == address(0)
                || _amBridge == address(0)
        ) {
            revert AddressZero();
        }
        worldIDIdentityManagerAddress = _worldIDIdentityManager;
        gnosisWorldIDAddress = _gnosisWorldIDAddress;
        amBridge = _amBridge;
        _gasLimitPropagateRoot = DEFAULT_GNOSIS_GAS_LIMIT;
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to the Gnosis chain
    /// @dev Calls this method on the L1 Proxy contract to relay roots to the destination Gnosis chain
    function propagateRoot() external {
        uint256 latestRoot = IWorldIDIdentityManager(worldIDIdentityManagerAddress).latestRoot();

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the Gnosis bridge
        bytes memory data = abi.encodeCall(IGnosisWorldID.receiveRoot, (latestRoot));

        IAMB(amBridge).requireToPassMessage(gnosisWorldIDAddress, data, _gasLimitPropagateRoot);

        emit RootPropagated(latestRoot);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on GnosisWorldID
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external onlyOwner {
        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the Gnosis bridge.
        bytes memory data = abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

        IAMB(amBridge).requireToPassMessage(gnosisWorldIDAddress, data, _gasLimitPropagateRoot);

        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    /// @notice Sets the gas limit for the propagateRoot method
    /// @param _gnosisGasLimit The new gas limit for the propagateRoot method
    function setGasLimitPropagateRoot(uint32 _gnosisGasLimit) external onlyOwner {
        if (_gnosisGasLimit <= 0) {
            revert GasLimitZero();
        }

        _gasLimitPropagateRoot = _gnosisGasLimit;

        emit SetGasLimitPropagateRoot(_gnosisGasLimit);
    }
}
