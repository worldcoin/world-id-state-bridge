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
        /*//////////////////////////////////////////////////////////////
                                POLYGON
        //////////////////////////////////////////////////////////////*/

        // https://static.matic.network/network/testnet/mumbai/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0xBbD7cBFA79faee899Eaf900F13C9065bF03B1A74);

        // FxRoot
        fxRootAddress = address(0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = new StateBridge(checkpointManagerAddress, fxRootAddress);

        vm.stopBroadcast();
    }
}
