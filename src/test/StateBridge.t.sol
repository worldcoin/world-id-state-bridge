// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {StateBridge} from "src/StateBridge.sol";
import {WorldIDIdentityManagerImplV1} from "src/mock/WorldIDIdentityManagerImplV1.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract StateBridgeTest is PRBTest, StdCheats {
    StateBridge public stateBridge;
    WorldIDIdentityManagerImplV1 public mockWorldID;
    address public owner;

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOptimism(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    function setUp() public {
        stateBridge =
            new StateBridge(address(0x1), address(0x1), address(0x1), address(0x1), address(0x1));
        owner = stateBridge.owner();
        mockWorldID = new WorldIDIdentityManagerImplV1();
        mockWorldID.initialize(address(stateBridge));
    }

    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.assume(newOwner != address(0x0));

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(owner);
        stateBridge.transferOwnership(newOwner);

        assertEq(stateBridge.owner(), newOwner);
    }

    function test_notOwner_transferOwnership_reverts(address newOwner) public {
        vm.assume(newOwner != address(0x0));

        vm.expectRevert("Ownable: caller is not the owner");

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        stateBridge.transferOwnership(newOwner);

        assertEq(stateBridge.owner(), owner);
    }

    function test_owner_transferOwnershipOptimism_succeeds(address newOwner, bool isLocal) public {
        vm.assume(newOwner != address(0x0));

        vm.expectEmit(true, true, true, true);

        // CrossDomainOwnable3.sol transferOwnership event
        emit OwnershipTransferredOptimism(owner, newOwner, isLocal);

        vm.prank(owner());
        stateBridge.transferOwnershipOptimism(newOwner, isLocal);
    }
}
