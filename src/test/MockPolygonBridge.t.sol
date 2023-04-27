pragma solidity ^0.8.15;

import {MockPolygonBridge} from "src/mock/MockPolygonBridge.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract MockPolygonBridgeTest is PRBTest, StdCheats {
    MockPolygonBridge polygonWorldID;

    address owner;

    /// @notice Thrown when root history expiry is set
    event RootHistoryExpirySet(uint256 rootHistoryExpiry);

    /// @notice Thrown when new root is inserted
    event ReceivedRoot(uint256 root, uint128 supersedeTimestamp);

    /// @notice Thrown when the message selector passed from FxRoot is invalid.
    error InvalidMessageSelector();

    function setUp() public {
        owner = address(0x1234);

        vm.label(owner, "owner");

        vm.prank(owner);
        polygonWorldID = new MockPolygonBridge();
    }

    /// @notice tests that receiveRoot succeeds if encoded properly
    function testReceiveRootSucceeds(uint256 newRoot, uint128 supersedeTimestamp) public {
        bytes memory message =
            abi.encodeWithSignature("receiveRoot(uint256,uint128)", newRoot, supersedeTimestamp);

        vm.expectEmit(true, true, true, true);

        emit ReceivedRoot(newRoot, supersedeTimestamp);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }

    /// @notice tests that setRootHistoryExpiry succeeds if encoded properly
    function testSetRootHistoryExpirySucceeds(uint256 rootHistoryExpiry) public {
        bytes memory message =
            abi.encodeWithSignature("setRootHistoryExpiry(uint256)", rootHistoryExpiry);

        vm.expectEmit(true, true, true, true);

        emit RootHistoryExpirySet(rootHistoryExpiry);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }

    /// @notice tests that an invalid function signature reverts
    function testProcessMessageFromRootReverts(bytes4 invalidFnSig, bytes32 param) public {
        vm.assume(
            invalidFnSig != bytes4(keccak256("receiveRoot(uint256,uint128)"))
                && invalidFnSig != bytes4(keccak256("setRootHistoryExpiry(uint256)"))
        );

        bytes memory message = abi.encode(invalidFnSig, param);

        vm.expectRevert(InvalidMessageSelector.selector);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(message);
    }
}
