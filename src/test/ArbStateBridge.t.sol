// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ArbStateBridge} from "src/arbStateBridge.sol";
import {WorldIDIdentityManagerMock} from "src/mock/WorldIDIdentityManagerMock.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title State Bridge Test
/// @author Worldcoin
/// @notice A test contract for StateBridge.sol
contract ArbStateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    ArbStateBridge public arbStateBridge;
    WorldIDIdentityManagerMock public mockWorldID;

    uint32 public opGasLimit;

    address public mockWorldIDAddress;

    address public owner;

    /// @notice The address of the OpWorldID contract on any OP Stack chain
    address public arbWorldIDAddress;

    /// @notice address for OP Stack chain Ethereum mainnet L1CrossDomainMessenger contract
    address public arbInboxAddress;

    uint256 public sampleRoot;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emmitted when the ownership transfer of ArbStateBridge is started (OZ Ownable2Step)
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /// @notice Emmitted when the ownership transfer of ArbStateBridge is accepted (OZ Ownable2Step)
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // @notice Emmitted when the the StateBridge sends a root to the OPWorldID contract
    /// @param root The root sent to the OPWorldID contract on the OP Stack chain
    event RootPropagated(uint256 root);

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism/OP Stack chain EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOp(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

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

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to a block where both Optimim's and Base's crossDomainMessenger contract is deployed
        /// @notice and the Base crossDomainMessenger ResolvedDelegateProxy target address is initialized
        vm.rollFork(17711915);

        if (block.chainid == 1) {
            arbInboxAddress = address(0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f);
        } else {
            revert invalidCrossDomainMessengerFork();
        }

        // inserting mock root
        sampleRoot = uint256(0x111);
        mockWorldID = new WorldIDIdentityManagerMock(sampleRoot);
        mockWorldIDAddress = address(mockWorldID);

        arbWorldIDAddress = address(0x1);

        arbStateBridge = new ArbStateBridge (
            mockWorldIDAddress,
            arbWorldIDAddress,
            arbInboxAddress
        );

        owner = arbStateBridge.owner();
    }

    ///////////////////////////////////////////////////////////////////
    ///                           SUCCEEDS                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice select a specific fork
    function test_canSelectFork_succeeds() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    function test_propagateRoot_suceeds() public {
        uint256 l1CallValue =
            arbStateBridge.getL1CallValue(arbStateBridge.RELAY_MESSAGE_L2_GAS_LIMIT());

        vm.expectEmit(true, true, true, true);
        emit RootPropagated(sampleRoot);

        arbStateBridge.propagateRoot{value: l1CallValue}();

        // Bridging is not emulated
    }

    /// @notice Tests that the owner of the StateBridge contract can transfer ownership
    /// using Ownable2Step transferOwnership
    /// @param newOwner the new owner of the contract
    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.assume(newOwner != address(0));

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnershipStarted event
        emit OwnershipTransferStarted(owner, newOwner);

        vm.prank(owner);
        arbStateBridge.transferOwnership(newOwner);

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        arbStateBridge.acceptOwnership();

        assertEq(arbStateBridge.owner(), newOwner);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Arbitrum
    /// @param _rootHistoryExpiry The new root history expiry for ArbWorldID
    function test_owner_setRootHistoryExpiry_succeeds(uint256 _rootHistoryExpiry) public {
        uint256 l1CallValue =
            arbStateBridge.getL1CallValue(arbStateBridge.RELAY_MESSAGE_L2_GAS_LIMIT());

        vm.expectEmit(true, true, true, true);
        emit SetRootHistoryExpiry(_rootHistoryExpiry);

        vm.prank(owner);
        arbStateBridge.setRootHistoryExpiry{value: l1CallValue}(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests whether the StateBridge contract can set root history expiry on Optimism and Polygon
    /// @param _rootHistoryExpiry The new root history expiry for OpWorldID and PolygonWorldID
    function test_notOwner_SetRootHistoryExpiry_reverts(
        address nonOwner,
        uint256 _rootHistoryExpiry
    ) public {
        vm.assume(nonOwner != owner && nonOwner != address(0) && _rootHistoryExpiry != 0);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        arbStateBridge.setRootHistoryExpiry(_rootHistoryExpiry);
    }

    /// @notice Tests that a nonPendingOwner can't accept ownership of StateBridge
    /// @param newOwner the new owner of the contract
    function test_notOwner_acceptOwnership_reverts(address newOwner, address randomAddress)
        public
    {
        vm.assume(
            newOwner != address(0) && randomAddress != address(0) && randomAddress != newOwner
        );

        vm.prank(owner);
        arbStateBridge.transferOwnership(newOwner);

        vm.expectRevert("Ownable2Step: caller is not the new owner");

        vm.prank(randomAddress);
        arbStateBridge.acceptOwnership();
    }

    /// @notice Tests that ownership can't be renounced
    function test_owner_renounceOwnership_reverts() public {
        vm.expectRevert(ArbStateBridge.CannotRenounceOwnership.selector);

        vm.prank(owner);
        arbStateBridge.renounceOwnership();
    }
}
