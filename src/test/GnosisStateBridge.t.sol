// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GnosisStateBridge} from "src/GnosisStateBridge.sol";
import {MockWorldIDIdentityManager} from "src/mock/MockWorldIDIdentityManager.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title State Bridge Test
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @notice A test contract for GnosisStateBridge.sol
contract GnosisStateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    GnosisStateBridge gnosisStateBridge;
    MockWorldIDIdentityManager public mockWorldID;

    /// @notice The addess of the AMB contract on the source network
    address public amBridge;

    /// @notice The address of the GnosisWorldID contract on any Gnosis chain
    address public gnosisWorldIDAddress;

    address public mockWorldIDAddress;
    uint256 public sampleRoot;
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

    /// @notice Emitted when the AMB sends a root to the GnosisWorldID contract
    /// @param root The root sent to the GnosisWorldID contract on the Gnosis chain
    event RootPropagated(uint256 root);

    /// @notice Emitted when the StateBridge sets the root history expiry for GnosisWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to set an address to zero
    error AddressZero();

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to a block where Gnosis AMB already has been deployed
        vm.rollFork(17711915);

        sampleRoot = uint256(0x123);
        mockWorldID = new MockWorldIDIdentityManager(sampleRoot);
        mockWorldIDAddress = address(mockWorldID);

        amBridge = address(0x4C36d2919e407f0Cc2Ee3c993ccF8ac26d9CE64e);

        gnosisWorldIDAddress = address(0x1);

        gnosisStateBridge =
            new GnosisStateBridge(mockWorldIDAddress, gnosisWorldIDAddress, amBridge);

        owner = gnosisStateBridge.owner();
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

    /// @notice tests that a root can be sent successfully to Gnosis
    function test_propagateRoot_succeeds(address randomAddress) public {
        vm.assume(randomAddress != address(0) && randomAddress != owner);

        vm.expectEmit(true, true, true, true);
        emit RootPropagated(sampleRoot);

        vm.prank(randomAddress);
        gnosisStateBridge.propagateRoot();
    }

    /// @notice Tests that the owner of the StateBridge contract can transfer ownership
    /// using Ownable2Step transferOwnership
    /// @param newOwner the new owner of the contract
    function test_owner_transferOwnership_succeeds(address newOwner) public {
        vm.assume(newOwner != address(0) && newOwner != owner);

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnershipStarted event
        emit OwnershipTransferStarted(owner, newOwner);

        vm.prank(owner);
        gnosisStateBridge.transferOwnership(newOwner);

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        gnosisStateBridge.acceptOwnership();

        assertEq(gnosisStateBridge.owner(), newOwner);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Gnosis
    /// @param _rootHistoryExpiry The new root history expiry for GnosisWorldID
    function test_owner_setRootHistoryExpiry_succeeds(uint256 _rootHistoryExpiry) public {
        vm.assume(owner != address(0));

        vm.expectEmit(true, true, true, true);
        emit SetRootHistoryExpiry(_rootHistoryExpiry);

        vm.prank(owner);
        gnosisStateBridge.setRootHistoryExpiry(_rootHistoryExpiry);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests that the StateBridge contract can't be constructed with a zero address for params
    function test_constructorParamsCannotBeZeroAddresses_reverts() public {
        vm.expectRevert(AddressZero.selector);
        gnosisStateBridge =
            new GnosisStateBridge(mockWorldIDAddress, gnosisWorldIDAddress, address(0));

        vm.expectRevert(AddressZero.selector);
        gnosisStateBridge = new GnosisStateBridge(mockWorldIDAddress, address(0), amBridge);

        vm.expectRevert(AddressZero.selector);
        gnosisStateBridge = new GnosisStateBridge(address(0), gnosisWorldIDAddress, amBridge);
    }

    /// @notice tests that the StateBridge contract's ownership can't be changed by a non-owner
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_notOwner_transferOwnership_reverts(address nonOwner, address newOwner) public {
        vm.assume(nonOwner != owner && nonOwner != address(0) && newOwner != address(0));

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        gnosisStateBridge.transferOwnership(newOwner);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Gnosis
    /// @param _rootHistoryExpiry The new root history expiry for GnosisWorldID
    function test_notOwner_setRootHistoryExpiry_reverts(
        address nonOwner,
        uint256 _rootHistoryExpiry
    ) public {
        vm.assume(nonOwner != owner && _rootHistoryExpiry != 0);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        gnosisStateBridge.setRootHistoryExpiry(_rootHistoryExpiry);
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
        gnosisStateBridge.transferOwnership(newOwner);

        vm.expectRevert("Ownable2Step: caller is not the new owner");

        vm.prank(randomAddress);
        gnosisStateBridge.acceptOwnership();
    }
}
