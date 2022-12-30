// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { OpWorldID } from "../src/OpWorldID.sol";

/// @title OpWorldIDTest
/// @author Worldcoin
/// @notice A test contract for OpWorldID
/// @dev The OpWorldID contract is deployed on Optimism and is called by the L1 Proxy contract.
contract OpWorldIDTest is PRBTest, StdCheats {
    /// @notice The OpWorldID contract
    OpWorldID internal id;

    /// @notice The root of the merkle tree before the first update
    uint256 preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;

    /// @notice The root of the merkle tree after the first update
    uint256 newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;

    function setUp() public {
        /// @notice The timestamp of the root of the merkle tree before the first update
        uint128 preRootTimestamp = uint128(block.timestamp);

        /// @notice Initialize the OpWorldID contract
        id = new OpWorldID(preRoot, preRootTimestamp);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "OPWorldID");
    }

    /// @notice Test that you can insert new root and check if it is valid
    function testReceiveVerifyRoot() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);
        id.receiveRoot(newRoot, newRootTimestamp);
        assertTrue(id.checkValidRoot(newRoot));
    }

    /// @notice Test that you can insert an invalid root and check that it is invalid
    function testReceiveVerifyInvalidRoot() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);
        uint256 randomRoot = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        id.receiveRoot(newRoot, newRootTimestamp);
        vm.expectRevert(OpWorldID.NonExistentRoot.selector);
        id.checkValidRoot(randomRoot);
    }

    /// @notice Test that you can insert a root and check it has expired if more than 7 days have passed
    function testExpiredRoot() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        id.receiveRoot(newRoot, newRootTimestamp);
        vm.warp(block.timestamp + 8 days);
        vm.expectRevert(OpWorldID.ExpiredRoot.selector);
        id.checkValidRoot(newRoot);
    }
}
