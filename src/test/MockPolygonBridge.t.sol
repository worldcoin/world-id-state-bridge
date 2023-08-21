pragma solidity ^0.8.15;

import {MockPolygonBridge} from "src/mock/MockPolygonBridge.sol";
import {WorldIDBridge} from "src/abstract/WorldIDBridge.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title Mock Polygon Bridge Test
/// @author Worldcoin
/// @notice Mock of the Polygon FxPortal Bridge to test low-level assembly functions
/// `grabSelector` and `stripSelector` in the PolygonWorldID contract
contract MockPolygonBridgeTest is PRBTest, StdCheats {
    MockPolygonBridge polygonWorldID;

    address owner;

    /// @notice The time in the `rootHistory` mapping associated with a root that has never been
    ///         seen before.
    uint128 internal constant NULL_ROOT_TIME = 0;

    /// @notice Emitted when root history expiry is set
    event RootHistoryExpirySet(uint256 rootHistoryExpiry);

    /// @notice Emitted when a new root is received by the contract.
    ///
    /// @param root The value of the root that was added.
    /// @param timestamp The timestamp of insertion for the given root.
    event RootAdded(uint256 root, uint128 timestamp);

    function setUp() public {
        owner = address(0x1234);

        vm.label(owner, "owner");

        vm.prank(owner);
        polygonWorldID = new MockPolygonBridge(uint8(30));
    }

    ///////////////////////////////////////////////////////////////////
    ///                           SUCCEEDS                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests that receiveRoot succeeds if encoded properly
    function test_ReceiveRoot_succeeds(uint256 newRoot) public {
        bytes memory message = abi.encodeWithSignature("receiveRoot(uint256)", newRoot);

        vm.expectEmit(true, true, true, true);

        emit RootAdded(newRoot, uint128(block.timestamp));

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }

    /// @notice tests that setRootHistoryExpiry succeeds if encoded properly
    function test_setRootHistoryExpiry_succeeds(uint256 rootHistoryExpiry) public {
        bytes memory message =
            abi.encodeWithSignature("setRootHistoryExpiry(uint256)", rootHistoryExpiry);

        vm.expectEmit(true, true, true, true);

        emit RootHistoryExpirySet(rootHistoryExpiry);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice tests that an invalid function signature reverts
    function test_processMessageFromRoot_reverts_InvalidMessageSelector(
        bytes4 invalidSelector,
        bytes32 param
    ) public {
        vm.assume(
            invalidSelector != bytes4(keccak256("receiveRoot(uint256)"))
                && invalidSelector != bytes4(keccak256("setRootHistoryExpiry(uint256)"))
        );

        bytes memory message = abi.encode(invalidSelector, param);

        vm.expectRevert(
            abi.encodeWithSelector(
                MockPolygonBridge.InvalidMessageSelector.selector, invalidSelector
            )
        );
        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }

    function test_processMessageFromRoot_reverts_CannotOverwriteRoot(uint256 newRoot) public {
        vm.assume(newRoot != 0);

        bytes memory message = abi.encodeWithSignature("receiveRoot(uint256)", newRoot);

        vm.expectEmit(true, true, true, true);
        emit RootAdded(newRoot, uint128(block.timestamp));

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);

        vm.expectRevert(abi.encodeWithSelector(WorldIDBridge.CannotOverwriteRoot.selector));

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }
}
