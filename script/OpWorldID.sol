// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../src/OpWorldID.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract OpWorldIDScrip is Script {
    OpWorldID internal opWorldID;

    function run() public {
        vm.startBroadcast();
        opWorldID = new OpWorldID();
        vm.stopBroadcast();
    }
}
