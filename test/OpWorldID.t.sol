// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { OpWorldID } from "../src/OpWorldID.sol";

/// @dev See the "Writing Tests" section in the Foundry Book if this is your first time with Forge.
/// https://book.getfoundry.sh/forge/writing-tests
contract OpWorldIDTest is PRBTest, StdCheats {
    OpWorldID internal id;
    uint256 preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
    uint256 newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;

    function setUp() public {
        uint128 preRootTimestamp = uint128(block.timestamp);
        id = new OpWorldID(preRoot, preRootTimestamp);

        vm.label(address(this), "Sender");
        vm.label(address(id), "OPWorldID");
    }

    function testReceiveRootPasses() external {
        vm.warp(block.timestamp + 200);
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        id.receiveRoot(newRoot, newRootTimestamp);
        assertTrue(id.checkValidRoot(newRoot));
    }

    /// @dev Run Forge with `-vvvv` to see console logs.
    function testExample() external {
        console2.log("Hello World");
        assertTrue(true);
    }
}
