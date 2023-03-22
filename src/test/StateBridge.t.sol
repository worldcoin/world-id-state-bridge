// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {StateBridge} from "src/StateBridge.sol";
import {WorldIDIdentityManagerImplV1} from "src/mock/WorldIDIdentityManagerImplV1.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract StateBridgeTest is PRBTest, StdCheats {
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    StateBridge public stateBridge;
    WorldIDIdentityManagerImplV1 public mockWorldID;

    address public mockWorldIDAddress;
    address public crossDomainMessengerAddress;
    address public fxRoot;
    address public checkpointManager;
    address public owner;

    uint256 public newRoot;

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    /// @param previousOwner The previous owner of the StateBridge contract
    /// @param newOwner The new owner of the StateBridge contract
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOptimism(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Emmitted when a root is sent to OpWorldID
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    event RootSentToOptimism(uint256 root, uint128 timestamp);

    /// @notice Emmitted when a root is sent to PolygonWorldID
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    event RootSentToPolygon(uint256 root, uint128 timestamp);

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to the block where Optimim's crossDomainMessenger contract is deployed
        vm.rollFork(16883118);

        if (block.chainid == 1) {
            crossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);
        } else {
            revert invalidCrossDomainMessengerFork();
        }

        mockWorldID = new WorldIDIdentityManagerImplV1();
        mockWorldIDAddress = address(mockWorldID);

        checkpointManager = address(0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287);
        fxRoot = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        stateBridge = new StateBridge(
            checkpointManager,
            fxRoot,
            mockWorldIDAddress,
            address(0x1),
            crossDomainMessengerAddress
        );

        newRoot = uint256(0x5d972fd7d82c7a734853ce8b9811040cd1459bae3b1f34d7ea557882ff2cab8f);

        owner = stateBridge.owner();
        mockWorldID.initialize(address(stateBridge));
    }

    /*//////////////////////////////////////////////////////////////
                                SUCCEEDS
    //////////////////////////////////////////////////////////////*/

    /// @notice select a specific fork
    function test_canSelectFork_succeeds() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    function test_sendRootMultichain_succeeds() public {
        mockWorldID.sendRootToStateBridge(newRoot);

        assertEq(mockWorldID.checkValidRoot(newRoot), true);

        uint128 timestamp = uint128(block.timestamp);

        vm.expectEmit(true, true, true, true);

        emit RootSentToOptimism(newRoot, timestamp);

        emit RootSentToPolygon(newRoot, timestamp);
    }

    /// @notice tests whether the owner of the StateBridge contract can transfer ownership of StateBridge
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.assume(newOwner != address(0));

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(owner);
        stateBridge.transferOwnership(newOwner);

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

    /*//////////////////////////////////////////////////////////////
                                REVERTS
    //////////////////////////////////////////////////////////////*/

    /// @notice tests that a root that is not is not a valid root in WorldID Identity Manager contract
    /// can't be sent to the StateBridge
    /// @param notNewRoot A root that is not a valid root in the WorldID Identity Manager contract
    function test_sendRootMultichain_reverts(uint256 notNewRoot) public {
        vm.assume(notNewRoot != newRoot);

        mockWorldID.sendRootToStateBridge(newRoot);

        vm.expectRevert(InvalidRoot.selector);

        stateBridge.sendRootMultichain(notNewRoot);

        assertEq(mockWorldID.checkValidRoot(notNewRoot), false);
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
}
