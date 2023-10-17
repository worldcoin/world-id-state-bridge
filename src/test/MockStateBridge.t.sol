pragma solidity ^0.8.15;

import {MockStateBridge} from "src/mock/MockStateBridge.sol";
import {MockWorldIDIdentityManager} from "src/mock/MockWorldIDIdentityManager.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title Mock State Bridge Test
/// @author Worldcoin
contract MockStateBridgeTest is PRBTest, StdCheats {
    MockStateBridge public mockStateBridge;
    MockWorldIDIdentityManager public mockWorldID;
    MockBridgedWorldID public mockBridgedWorldID;

    address public owner;

    uint8 public treeDepth;

    uint256 public initialRoot;

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

        treeDepth = uint8(30);

        initialRoot = uint256(0x111);


        vm.prank(owner);
        mockBridgedWorldID = new MockBridgedWorldID(treeDepth);

        vm.prank(owner);
        mockWorldID = new MockWorldIDIdentityManager(initialRoot);


        vm.prank(owner);
        mockStateBridge = new MockStateBridge(address(mockWorldID), address(mockBridgedWorldID));

        vm.prank(owner);
        mockBridgedWorldID.transferOwnership(address(mockStateBridge));
    }

    function testPropagateRootSucceeds() public {
        vm.expectEmit(true, true, true, true);
        emit RootAdded(initialRoot, uint128(block.timestamp));
        
        mockStateBridge.propagateRoot();

        assert(mockWorldID.latestRoot() == mockBridgedWorldID.latestRoot());
    }

}
