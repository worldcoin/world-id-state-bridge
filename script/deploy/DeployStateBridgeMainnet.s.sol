// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x8438ba278cF0bf6dc75a844755C7A805BB45984F
// https://goerli.etherscan.io/address/0x8438ba278cf0bf6dc75a844755c7a805bb45984f#code

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
