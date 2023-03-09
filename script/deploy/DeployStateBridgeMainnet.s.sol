// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "../../src/StateBridge.sol";

contract DeployStateBridge is Script {
    StateBridge public bridge;

    address public checkpointManagerAddress;
    address public fxRootAddress;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, "privateKey"), (uint256));

    function setup() public {
        /*//////////////////////////////////////////////////////////////
                                POLYGON
        //////////////////////////////////////////////////////////////*/

        // https://static.matic.network/network/mainnet/v1/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);
        // FxRoot
        fxRootAddress = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new StateBridge(checkpointManagerAddress, fxRootAddress);

        vm.stopBroadcast();
    }
}
