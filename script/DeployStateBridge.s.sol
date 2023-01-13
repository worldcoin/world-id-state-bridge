// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { StateBridge } from "../src/StateBridge.sol";

contract DeployStateBridge is Script {
    StateBridge public bridge;

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = new StateBridge();

        vm.stopBroadcast();
    }
}
