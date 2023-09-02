// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Arbitrum interface for cross domain messaging
import {IInbox} from "@arbitrum-nitro-contracts/bridge/IInbox.sol";
import {IOpWorldID} from "./interfaces/IOpWorldID.sol";
import {IRootHistory} from "./interfaces/IRootHistory.sol";
import {IWorldIDIdentityManager} from "./interfaces/IWorldIDIdentityManager.sol";
import {Ownable2Step} from "openzeppelin-contracts/access/Ownable2Step.sol";
import {ICrossDomainOwnable3} from "./interfaces/ICrossDomainOwnable3.sol";

/// @title World ID State Bridge Arbitrum
/// @author Worldcoin
/// @notice Distributes new World ID Identity Manager roots to an OP Stack network
/// @dev This contract lives on Ethereum mainnet and works for Optimism and any OP Stack based chain
contract ArbStateBridge is Ownable2Step {
    uint32 public constant RELAY_MESSAGE_L2_GAS_LIMIT = 2_000_000;

    ///////////////////////////////////////////////////////////////////
    ///                           STORAGE                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The address of the OpWorldID contract on any OP Stack chain
    address public immutable arbWorldIDAddress;

    address public immutable inbox;

    /// @notice Ethereum mainnet worldID Address
    address public immutable worldIDAddress;

    // Amount of ETH allocated to pay for the base submission fee. The base submission fee is a parameter unique to
    // retryable transactions; the user is charged the base submission fee to cover the storage costs of keeping their
    // ticket’s calldata in the retry buffer. (current base submission fee is queryable via
    // ArbRetryableTx.getSubmissionPrice). ArbRetryableTicket precompile interface exists at L2 address
    // 0x000000000000000000000000000000000000006E.
    uint256 internal l2MaxSubmissionCost;

    // L2 Gas price bid for immediate L2 execution attempt (queryable via standard eth*gasPrice RPC)
    uint256 internal l2GasPrice;

    // uint32 internal _gasLimitTransferOwnership;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism/OP Stack chain EOA/contract)
    /// or an Ethereum EOA or contract
    event OwnershipTransferredOp(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Emmitted when the the StateBridge sends a root to the OPWorldID contract
    /// @param root The root sent to the OPWorldID contract on the OP Stack chain
    event RootPropagated(uint256 root);

    /// @notice Emmitted when the the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emmitted when the the StateBridge sets the gas limit for sendRootOp
    /// @param _opGasLimit The new opGasLimit for sendRootOp
    event SetGasLimitSendRoot(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the gas limit for SetRootHistoryExpiryt
    /// @param _opGasLimit The new opGasLimit for SetRootHistoryExpirytimism
    event SetGasLimitSetRootHistoryExpiry(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the gas limit for transferOwnershipOp
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    event SetGasLimitTransferOwnershipOp(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

    ///////////////////////////////////////////////////////////////////
    ///                         CONSTRUCTOR                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _arbWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// @param _inbox aa
    /// Stack network
    constructor(address _worldIDIdentityManager, address _arbWorldIDAddress, address _inbox) {
        arbWorldIDAddress = _arbWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        inbox = _inbox;

        l2MaxSubmissionCost = 0.01e18;
        l2GasPrice = 5e9; // 5 gwei
    }

    ///////////////////////////////////////////////////////////////////
    ///                          PUBLIC API                         ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Sends the latest WorldID Identity Manager root to the IOpStack.
    /// @dev Calls this method on the L1 Proxy contract to relay roots to the destination OP Stack chain
    function propagateRoot() external payable {
        uint256 latestRoot = IWorldIDIdentityManager(worldIDAddress).latestRoot();

        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the optimism bridge.
        bytes memory message = abi.encodeCall(IOpWorldID.receiveRoot, (latestRoot));

        IInbox(inbox).createRetryableTicket{value: msg.value}(
            arbWorldIDAddress, // destAddr destination L2 contract address
            0, // l2CallValue call value for retryable L2 message
            l2MaxSubmissionCost, // maxSubmissionCost Max gas deducted from user's L2 balance to cover base fee
            msg.sender, // excessFeeRefundAddress maxgas * gasprice - execution cost gets credited here on L2
            msg.sender, // callValueRefundAddress l2Callvalue gets credited here on L2 if retryable txn times out or gets cancelled
            RELAY_MESSAGE_L2_GAS_LIMIT, // maxGas Max gas deducted from user's L2 balance to cover L2 execution
            l2GasPrice, // gasPriceBid price bid for L2 execution
            message // function call
        );

        emit RootPropagated(latestRoot);
    }

    /// @notice Adds functionality to the StateBridge to set the root history expiry on OpWorldID
    /// @param _rootHistoryExpiry new root history expiry
    function setRootHistoryExpiry(uint256 _rootHistoryExpiry) external payable onlyOwner {
        // The `encodeCall` function is strongly typed, so this checks that we are passing the
        // correct data to the optimism bridge.
        bytes memory message =
            abi.encodeCall(IRootHistory.setRootHistoryExpiry, (_rootHistoryExpiry));

        IInbox(inbox).createRetryableTicket{value: msg.value}(
            arbWorldIDAddress, // destAddr destination L2 contract address
            0, // l2CallValue call value for retryable L2 message
            l2MaxSubmissionCost, // maxSubmissionCost Max gas deducted from user's L2 balance to cover base fee
            msg.sender, // excessFeeRefundAddress maxgas * gasprice - execution cost gets credited here on L2
            msg.sender, // callValueRefundAddress l2Callvalue gets credited here on L2 if retryable txn times out or gets cancelled
            RELAY_MESSAGE_L2_GAS_LIMIT, // maxGas Max gas deducted from user's L2 balance to cover L2 execution
            l2GasPrice, // gasPriceBid price bid for L2 execution
            message // function call
        );

        emit SetRootHistoryExpiry(_rootHistoryExpiry);
    }

    /**
     * @notice Returns required amount of ETH to send a message via the Inbox.
     * @return amount of ETH that this contract needs to hold in order for relayMessage to succeed.
     */
    function getL1CallValue(uint32 l2GasLimit) external view returns (uint256) {
        return _getL1CallValue(l2GasLimit);
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

    /**
     * @notice Returns required amount of ETH to send a message via the Inbox.
     * @return amount of ETH that this contract needs to hold in order for relayMessage to succeed.
     */
    function _getL1CallValue(uint32 l2GasLimit) internal view returns (uint256) {
        return l2MaxSubmissionCost + l2GasPrice * l2GasLimit;
    }
}
