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
    error InvalidMessageSelector(bytes4 selector);

    function setUp() public {
        owner = address(0x1234);

        vm.label(owner, "owner");

        vm.prank(owner);
        polygonWorldID = new MockPolygonBridge();
    }

    function testReceiveRootSucceeds(uint256 newRoot, uint128 supersedeTimestamp) public {
        bytes memory rootData = abi.encode(newRoot, supersedeTimestamp);

        bytes memory data = abi.encodeWithSignature("receiveRoot(bytes32)", rootData);

        vm.expectEmit(true, true, true, true);

        emit ReceivedRoot(newRoot, supersedeTimestamp);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(data);
    }

    function testSetRootHistoryExpirySucceeds(uint256 rootHistoryExpiry) public {
        bytes memory rootHistoryExpiryData = abi.encode(rootHistoryExpiry);

        bytes memory data =
            abi.encodeWithSignature("setRootHistoryExpiry(uint256)", rootHistoryExpiryData);

        vm.expectEmit(true, true, true, true);

        emit RootHistoryExpirySet(rootHistoryExpiry);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(data);
    }

    function testProcessMessageFromRootReverts() public {
        uint256 num = 1;
        bytes memory data = abi.encodeWithSignature("invalidFnSig(uint256)", num);

        vm.expectRevert(InvalidMessageSelector.selector);

        vm.prank(owner);
        polygonWorldID.processMessageFromRoot(data);
    }
}
