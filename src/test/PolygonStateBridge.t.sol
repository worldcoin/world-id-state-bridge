// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {PolygonStateBridge} from "src/PolygonStateBridge.sol";
import {WorldIDIdentityManagerMock} from "src/mock/WorldIDIdentityManagerMock.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title State Bridge Test
/// @author Worldcoin
/// @notice A test contract for StateBridge.sol
contract PolygonStateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    PolygonStateBridge polygonStateBridge;
    WorldIDIdentityManagerMock public mockWorldID;

    uint32 public opGasLimit;

    address public mockWorldIDAddress;

    address public fxRoot;
    address public checkpointManager;
    address public owner;
    uint256 public sampleRoot;

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

    /// @notice Emitted when the the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    // @notice Emitted when the owner calls setFxChildTunnel for the first time
    event SetFxChildTunnel(address fxChildTunnel);

    /// @notice Emitted when a root is sent to PolygonWorldID
    /// @param root The latest WorldID Identity Manager root.
    event RootPropagated(uint256 root);

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to a block where FXPortal already has been deployed
        /// @notice and the Base crossDomainMessenger ResolvedDelegateProxy target address is initialized
        vm.rollFork(17711915);

        sampleRoot = uint256(0x123);
        mockWorldID = new WorldIDIdentityManagerMock(sampleRoot);
        mockWorldIDAddress = address(mockWorldID);

        checkpointManager = address(0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287);
        fxRoot = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        polygonStateBridge = new PolygonStateBridge (
            checkpointManager,
            fxRoot,
            mockWorldIDAddress
        );

        owner = polygonStateBridge.owner();
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

    /// @notice tests that a root can be sent successfully to Polygon
    function test_propagateRoot_succeeds(address randomAddress) public {
        vm.assume(randomAddress != address(0) && randomAddress != owner);

        vm.expectEmit(true, true, true, true);

        emit RootPropagated(sampleRoot);

        vm.prank(randomAddress);
        polygonStateBridge.propagateRoot();
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
        polygonStateBridge.transferOwnership(newOwner);

        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable2Step transferOwnership event
        emit OwnershipTransferred(owner, newOwner);

        vm.prank(newOwner);
        polygonStateBridge.acceptOwnership();

        assertEq(polygonStateBridge.owner(), newOwner);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Optimism and Polygon
    /// @param _rootHistoryExpiry The new root history expiry for OpWorldID and PolygonWorldID
    function test_owner_setRootHistoryExpiryPolygon_succeeds(uint256 _rootHistoryExpiry) public {
        vm.assume(owner != address(0));

        vm.expectEmit(true, true, true, true);
        emit SetRootHistoryExpiry(_rootHistoryExpiry);

        vm.prank(owner);
        polygonStateBridge.setRootHistoryExpiryPolygon(_rootHistoryExpiry);
    }

    /// @notice tests that the owner of the StateBridge contract can set the fxChildTunnel
    /// @param newFxChildTunnel the new fxChildTunnel
    function test_owner_setFxChildTunnel(address newFxChildTunnel) public {
        vm.assume(newFxChildTunnel != address(0));

        vm.expectEmit(true, true, true, true);
        emit SetFxChildTunnel(newFxChildTunnel);

        vm.prank(owner);
        polygonStateBridge.setFxChildTunnel(newFxChildTunnel);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests that the StateBridge contract can't be constructed with a zero address for params
    function test_constructorParamsCannotBeZeroAddresses_reverts() public {
        vm.expectRevert("WorldIDIdentityManager cannot be the zero address");
        polygonStateBridge = new PolygonStateBridge(
            checkpointManager,
            fxRoot,
            address(0)
        );

        vm.expectRevert("fxRoot cannot be the zero address");
        polygonStateBridge = new PolygonStateBridge(
            checkpointManager,
            address(0),
            mockWorldIDAddress
        );

        vm.expectRevert("checkpointManager cannot be the zero address");
        polygonStateBridge = new PolygonStateBridge(
            address(0),
            fxRoot,
            mockWorldIDAddress
        );
    }

    /// @notice tests that the StateBridge contract's ownership can't be changed by a non-owner
    /// @param newOwner The new owner of the StateBridge contract (foundry fuzz)
    function test_notOwner_transferOwnership_reverts(address nonOwner, address newOwner) public {
        vm.assume(nonOwner != owner && nonOwner != address(0) && newOwner != address(0));

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        polygonStateBridge.transferOwnership(newOwner);
    }

    /// @notice tests whether the StateBridge contract can set root history expiry on Optimism and Polygon
    /// @param _rootHistoryExpiry The new root history expiry for OpWorldID and PolygonWorldID
    function test_notOwner_setRootHistoryExpiryPolygon_reverts(
        address nonOwner,
        uint256 _rootHistoryExpiry
    ) public {
        vm.assume(nonOwner != owner && _rootHistoryExpiry != 0);

        vm.expectRevert("Ownable: caller is not the owner");

        vm.prank(nonOwner);
        polygonStateBridge.setRootHistoryExpiryPolygon(_rootHistoryExpiry);
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
        polygonStateBridge.transferOwnership(newOwner);

        vm.expectRevert("Ownable2Step: caller is not the new owner");

        vm.prank(randomAddress);
        polygonStateBridge.acceptOwnership();
    }

    /// @notice Tests that ownership can't be renounced
    function test_owner_renounceOwnership_reverts() public {
        vm.expectRevert(PolygonStateBridge.CannotRenounceOwnership.selector);

        vm.prank(owner);
        polygonStateBridge.renounceOwnership();
    }
}
