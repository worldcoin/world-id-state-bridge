// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { Bridge } from "../src/Bridge.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract BridgeScript is Script {
    Bridge internal bridge;

    function run() public {
        vm.startBroadcast();
        bridge = new Bridge();
        vm.stopBroadcast();
    }
}
