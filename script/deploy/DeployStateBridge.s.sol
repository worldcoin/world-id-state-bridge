// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "../../src/StateBridge.sol";

contract DeployStateBridge is Script {
    StateBridge public bridge;

    address public checkpointManagerAddress;
    address public fxRootAddress;

    function setup() public {
        // TBD
        checkpointManagerAddress = address(0x38b421a8A92375A356224F15CDE7AA94F64d371a);
        fxRootAddress = address(0x38b421a8A92375A356224F15CDE7AA94F64d371a);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = new StateBridge(checkpointManagerAddress, fxRootAddress);

        vm.stopBroadcast();
    }
}
