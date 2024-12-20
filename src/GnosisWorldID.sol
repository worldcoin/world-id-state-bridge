pragma solidity ^0.8.15;

import {WorldIDBridge} from "./abstract/WorldIDBridge.sol";
import {IGnosisWorldID} from "./interfaces/IGnosisWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import {IAMB} from "./interfaces/IAMB.sol";

/// @title Gnosis World ID Bridge
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on
///         Gnosis.
/// @dev This contract is deployed on Gnosis and is called by the L1 Proxy contract for each new
///      root insertion.
contract GnosisWorldID is WorldIDBridge, IGnosisWorldID, Ownable2Step, IRootHistory {
    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the Arbitrary Message Bridge contract on the Gnosis network
    address public immutable amBridge;

    /// @notice The address of the trusted sender (the bridge contract on the source network)
    address public trustedSender;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Thrown when setTrustedSender is called for the first time
    event SetTrustedSender(address trustedSender);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    /// @notice Emitted when an attempt is made to call the contract from an invalid address
    error InvalidCaller();

    /// @notice Emitted when an attempt is made to call the contract by an invalid sender (not by the state bridge)
    error InvalidSender();

    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract the depth of the associated merkle tree.
    ///
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    constructor(uint8 _treeDepth, address _amb) WorldIDBridge(_treeDepth) {
        if (_amb == address(0)) {
            revert AddressZero();
        }
        amBridge = _amb;
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// @param newRoot The value of the new root.
    function receiveRoot(uint256 newRoot) external virtual override {
        // only the AMB contract can call this function
        if (msg.sender != amBridge) {
            revert InvalidCaller();
        }

        // only the trusted sender (the bridge contract on the sourc chain) can call this function
        if (IAMB(amBridge).messageSender() != trustedSender) {
            revert InvalidSender();
        }

        _receiveRoot(newRoot);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the amount of time it takes for a root in the root history to expire.
    ///
    /// @param expiryTime The new amount of time it takes for a root to expire.
    ///
    /// @custom:reverts string If the caller is not the owner.
    function setRootHistoryExpiry(uint256 expiryTime)
        public
        override(IRootHistory, WorldIDBridge)
    {
        // only the AMB contract can call this function
        if (msg.sender != amBridge) {
            revert InvalidCaller();
        }

        // only the trusted sender (the bridge contract on the sourc chain) can call this function
        if (IAMB(amBridge).messageSender() != trustedSender) {
            revert InvalidSender();
        }

        _setRootHistoryExpiry(expiryTime);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                             SENDER MANAGEMENT                           ///
    ///////////////////////////////////////////////////////////////////////////////

    function setTrustedSender(address _trustedSender) external virtual onlyOwner {
        trustedSender = _trustedSender;
        emit SetTrustedSender(_trustedSender);
    }
}
