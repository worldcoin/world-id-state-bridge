// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {StateBridge} from "src/StateBridge.sol";
import {WorldIDIdentityManagerMock} from "src/mock/WorldIDIdentityManagerMock.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title State Bridge Test
/// @author Worldcoin
/// @notice A test contract for StateBridge.sol
contract StateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    StateBridge public stateBridge;
    WorldIDIdentityManagerMock public mockWorldID;

    uint32 public opGasLimit;

    address public mockWorldIDAddress;
    address public crossDomainMessengerAddress;
    address public opCrossDomainMessengerAddress;
    address public baseCrossDomainMessengerAddress;

    address public fxRoot;
    address public checkpointManager;
    address public owner;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    /// @param previousOwner The previous owner of the StateBridge contract
    /// @param newOwner The new owner of the StateBridge contract
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice OpenZeppelin Ownable2Step transferOwnership event
    /// @param previousOwner The previous owner of the StateBridge contract
    /// @param newOwner The new owner of the StateBridge contract
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

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

    /// @notice Emmitted when a root is sent to PolygonWorldID and OpworldID
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    event RootSentMultichain(uint256 root, uint128 timestamp);

    /// @notice Emmitted when the the StateBridge sets the opGasLimit for sendRootOptimism
    /// @param _opGasLimit The new opGasLimit for sendRootOptimism
    event SetOpGasLimitSendRootOptimism(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the opGasLimit for setRootHistoryExpiryOptimism
    /// @param _opGasLimit The new opGasLimit for setRootHistoryExpiryOptimism
    event SetOpGasLimitSetRootHistoryExpiryOptimism(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the opGasLimit for transferOwnershipOptimism
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    event SetOpGasLimitTransferOwnershipOptimism(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice
    error NotWorldIDIdentityManager();

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to a block where both Optimim's and Base's crossDomainMessenger contract is deployed
        /// @notice and the Base crossDomainMessenger ResolvedDelegateProxy target address is initialized
        vm.rollFork(17711915);


        if (block.chainid == 1) {
            opCrossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);
            baseCrossDomainMessengerAddress = address(0x866E82a600A1414e583f7F13623F1aC5d58b0Afa);
        } else {
            revert invalidCrossDomainMessengerFork();
        }

        mockWorldID = new WorldIDIdentityManagerMock();
        mockWorldIDAddress = address(mockWorldID);

        checkpointManager = address(0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287);
        fxRoot = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        address opWorldIDAddress = address(0x1);
        address baseWorldIDAddress = address(0x2);

        stateBridge = new StateBridge(
            checkpointManager,
            fxRoot,
            mockWorldIDAddress,
            opWorldIDAddress,
            opCrossDomainMessengerAddress,
            baseWorldIDAddress,
            baseCrossDomainMessengerAddress
        );

        owner = stateBridge.owner();
        mockWorldID.initialize(address(stateBridge));
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

    /// @notice tests that a root can be sent successfully to other networks
    function test_sendRootMultichain_succeeds(uint256 newRoot) public {
        uint128 timestamp = uint128(block.timestamp);

        vm.expectEmit(true, true, true, true);

        emit RootSentMultichain(newRoot, timestamp);

        mockWorldID.sendRootToStateBridge(newRoot);

        assertEq(mockWorldID.checkValidRoot(newRoot), true);
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
        stateBridge.transferOwnership(newOwner);

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        stateBridge.acceptOwnership();

        assertEq(stateBridge.owner(), newOwner);
    }

    /// @notice tests whether the StateBridge contract can transfer ownership of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract (foundry fuzz)
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    function test_owner_transferOwnershipOptimism_succeeds(address newOwner, bool isLocal) public {
        vm.assume(newOwner != address(0));

        vm.expectEmit(true, true, true, true);

        // CrossDomainOwnable3.sol transferOwnership event
        emit OwnershipTransferredOptimism(owner, newOwner, isLocal);

        vm.prank(owner);
        stateBridge.transferOwnershipOptimism(newOwner, isLocal);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Optimism and Polygon
    /// @param _rootHistoryExpiry The new root history expiry for OpWorldID and PolygonWorldID
    function test_owner_setRootHistoryExpiry_succeeds(uint256 _rootHistoryExpiry) public {
        vm.assume(_rootHistoryExpiry != 0);

        vm.expectEmit(true, true, true, true);
        emit SetRootHistoryExpiry(_rootHistoryExpiry);

        vm.prank(mockWorldIDAddress);
        stateBridge.setRootHistoryExpiry(_rootHistoryExpiry);
    }

    /// @notice tests whether the StateBridge contract can set the opGasLimit for sendRootOptimism
    /// @param _opGasLimit The new opGasLimit for sendRootOptimism
    function test_owner_setOpGasLimitSendRootOptimism_succeeds(uint32 _opGasLimit) public {
        vm.assume(_opGasLimit != 0);

        vm.expectEmit(true, true, true, true);

        emit SetOpGasLimitSendRootOptimism(_opGasLimit);

        vm.prank(owner);
        stateBridge.setOpGasLimitSendRootOptimism(_opGasLimit);
    }

    /// @notice tests whether the StateBridge contract can set the opGasLimit for setRootHistoryExpiryOptimism
    /// @param _opGasLimit The new opGasLimit for setRootHistoryExpiryOptimism
    function test_owner_setOpGasLimitSetRootHistoryExpiryOptimism_succeeds(uint32 _opGasLimit)
        public
    {
        vm.assume(_opGasLimit != 0);

        vm.expectEmit(true, true, true, true);

        emit SetOpGasLimitSetRootHistoryExpiryOptimism(_opGasLimit);

        vm.prank(owner);
        stateBridge.setOpGasLimitSetRootHistoryExpiryOptimism(_opGasLimit);
    }

    /// @notice tests whether the StateBridge contract can set the opGasLimit for transferOwnershipOptimism
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    function test_owner_setOpGasLimitTransferOwnershipOptimism_succeeds(uint32 _opGasLimit)
        public
    {
        vm.assume(_opGasLimit != 0);

        vm.expectEmit(true, true, true, true);

        emit SetOpGasLimitTransferOwnershipOptimism(_opGasLimit);

        vm.prank(owner);
        stateBridge.setOpGasLimitTransferOwnershipOptimism(_opGasLimit);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests that a root that is not is not a valid root in WorldID Identity Manager contract
    /// can't be sent to the StateBridge
    function test_sendRootMultichain_reverts(uint256 newRoot, address notWorldID) public {
        vm.assume(notWorldID != mockWorldIDAddress);

        vm.expectRevert(StateBridge.NotWorldIDIdentityManager.selector);
        vm.prank(notWorldID);
        stateBridge.sendRootMultichain(newRoot);
    }

    /// @notice tests that the StateBridge contract's ownership can't be changed by a non-owner
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_notOwner_transferOwnership_reverts(address nonOwner, address newOwner) public {
        vm.assume(nonOwner != owner && nonOwner != address(0) && newOwner != address(0));

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        stateBridge.transferOwnership(newOwner);
    }

    /// @notice tests that the StateBridge contract's ownership can't be changed by a non-owner
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_notOwner_transferOwnershipOptimism_reverts(
        address nonOwner,
        address newOwner,
        bool isLocal
    ) public {
        vm.assume(nonOwner != owner && newOwner != address(0x0));

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        stateBridge.transferOwnershipOptimism(newOwner, isLocal);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Optimism and Polygon
    /// @param _rootHistoryExpiry The new root history expiry for OpWorldID and PolygonWorldID
    function test_notOwner_setRootHistoryExpiry_reverts(
        address nonWorldID,
        uint256 _rootHistoryExpiry
    ) public {
        vm.assume(nonWorldID != mockWorldIDAddress && _rootHistoryExpiry != 0);

        vm.expectRevert(NotWorldIDIdentityManager.selector);

        vm.prank(nonWorldID);
        stateBridge.setRootHistoryExpiry(_rootHistoryExpiry);
    }

    /// @notice Tests that a nonPendingOwner can't accept ownership of StateBridge
    /// @param newOwner the new owner of the contract
    function test_notOwner_acceptOwnership_reverts(address newOwner, address randomAddress)
        public
    {
        vm.assume(newOwner != address(0) && randomAddress != address(0));

        vm.prank(owner);
        stateBridge.transferOwnership(newOwner);

        vm.expectRevert("Ownable2Step: caller is not the new owner");

        vm.prank(randomAddress);
        stateBridge.acceptOwnership();
    }

    /// @notice Tests that ownership can't be renounced
    function test_owner_renounceOwnership_reverts() public {
        vm.expectRevert(StateBridge.CannotRenounceOwnership.selector);

        vm.prank(owner);
        stateBridge.renounceOwnership();
    }
}
