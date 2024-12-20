// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GnosisWorldID} from "src/GnosisWorldID.sol";
import {SemaphoreTreeDepthValidator} from "src/utils/SemaphoreTreeDepthValidator.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title GnosisWorldIDTest
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @notice A test contract for GnosisWorldID
contract GnosisWorldIDTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                           WORLD ID                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice The GnosisWorldID contract
    GnosisWorldID internal id;

    /// @notice MarkleTree depth
    uint8 internal treeDepth = 16;

    /// @notice demo address
    address public owner = address(0x1111111);

    address public amb = address(0x2222222);

    /// @notice Thrown when setTrustedSender is called for the first time
    event SetTrustedSender(address trustedSender);

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    function setUp() public {
        /// @notice Initialize the GnosisWorldID contract
        vm.prank(owner);
        id = new GnosisWorldID(treeDepth, amb);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "GnosisWorldID");
    }

    ///////////////////////////////////////////////////////////////////
    ///                            TESTS                            ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Tests that the owner of the GnosisWorldID contract can transfer ownership
    /// using Ownable2Step transferOwnership
    /// @param newOwner the new owner of the contract
    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.prank(owner);
        id.transferOwnership(newOwner);

        vm.prank(newOwner);
        id.acceptOwnership();

        assertEq(id.owner(), newOwner);
    }

    function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(!SemaphoreTreeDepthValidator.validate(actualTreeDepth));
        vm.expectRevert(abi.encodeWithSignature("UnsupportedTreeDepth(uint8)", actualTreeDepth));

        new GnosisWorldID(actualTreeDepth, amb);
    }

    /// @notice Checks that it is possible to get the tree depth the contract was initialized with.
    function testCanGetTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(SemaphoreTreeDepthValidator.validate(actualTreeDepth));

        id = new GnosisWorldID(actualTreeDepth, amb);

        // Test
        assert(id.getTreeDepth() == actualTreeDepth);
    }

    /// @notice Checks that calling the placeholder setRootHistoryExpiry function reverts.
    function testSetRootHistoryExpiryReverts(uint256 expiryTime) public {
        // Test
        vm.expectRevert(abi.encodeWithSignature("InvalidCaller()"));
        id.setRootHistoryExpiry(expiryTime);
    }

    /// @notice checks that the owner of the GnosisWorldID contract can set the trustedSender (state bridge on the source chain)
    /// @param newTrustedSender the new trustedSender
    function testOwnerCanSetTrustedSender(address newTrustedSender) public {
        vm.assume(newTrustedSender != address(0));

        vm.expectEmit(true, true, true, true);
        emit SetTrustedSender(newTrustedSender);

        vm.prank(owner);
        id.setTrustedSender(newTrustedSender);
    }

    /// @notice Tests that the AMB can't be set to the zero address
    function test_cannotSetAMBToZero_reverts() public {
        vm.expectRevert(AddressZero.selector);

        vm.prank(owner);
        new GnosisWorldID(treeDepth, address(0));
    }

    /// @notice Tests that a nonPendingOwner can't accept ownership of GnosisWorldID
    /// @param newOwner the new owner of the contract
    function test_notOwner_acceptOwnership_reverts(address newOwner, address randomAddress)
        public
    {
        vm.assume(
            newOwner != address(0) && randomAddress != address(0) && randomAddress != newOwner
        );

        vm.prank(owner);
        id.transferOwnership(newOwner);

        vm.expectRevert("Ownable2Step: caller is not the new owner");

        vm.prank(randomAddress);
        id.acceptOwnership();
    }
}
