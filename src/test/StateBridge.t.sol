// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { StateBridge } from "src/StateBridge.sol";
import { WorldIDIdentityManagerImplV1 } from "src/mock/WorldIDIdentityManagerImplV1.sol";

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

contract StateBridgeTest is PRBTest, StdCheats {
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    StateBridge public stateBridge;
    WorldIDIdentityManagerImplV1 public mockWorldID;

    address public crossDomainMessengerAddress;
    address public owner;

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    /// @param previousOwner The previous owner of the StateBridge contract
    /// @param newOwner The new owner of the StateBridge contract
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOptimism(address indexed previousOwner, address indexed newOwner, bool isLocal);

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

        stateBridge = new StateBridge(
            address(0x1),
            address(0x1),
            address(0x1),
            address(0x1),
            crossDomainMessengerAddress
        );

        owner = stateBridge.owner();
        mockWorldID = new WorldIDIdentityManagerImplV1();
        mockWorldID.initialize(address(stateBridge));
    }

    /// @notice select a specific fork
    function test_canSelectFork_succeeds() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    /// @notice tests whether the owner of the StateBridge contract can transfer ownership of StateBridge
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.assume(newOwner != address(0x0));

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(owner);
        stateBridge.transferOwnership(newOwner);

        assertEq(stateBridge.owner(), newOwner);
    }

    /// @notice tests that the StateBridge contract's ownership can't be changed by a non-owner
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_notOwner_transferOwnership_reverts(address newOwner) public {
        vm.assume(newOwner != address(0x0));

        vm.expectRevert("Ownable: caller is not the owner");

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        stateBridge.transferOwnership(newOwner);

        assertEq(stateBridge.owner(), owner);
    }

    /// @notice tests whether the StateBridge contract can transfer ownership of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract (foundry fuzz)
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    function test_owner_transferOwnershipOptimism_succeeds(address newOwner, bool isLocal) public {
        vm.assume(newOwner != address(0x0));

        vm.expectEmit(true, true, true, true);

        // CrossDomainOwnable3.sol transferOwnership event
        emit OwnershipTransferredOptimism(owner, newOwner, isLocal);

        vm.prank(stateBridge.owner());
        stateBridge.transferOwnershipOptimism(newOwner, isLocal);
    }
}
