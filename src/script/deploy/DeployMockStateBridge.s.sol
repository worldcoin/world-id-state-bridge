// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Demo deployments
// Goerli 0x8438ba278cF0bf6dc75a844755C7A805BB45984F
// https://goerli.etherscan.io/address/0x8438ba278cf0bf6dc75a844755c7a805bb45984f#code

import {Script} from "forge-std/Script.sol";
import {MockStateBridge} from "src/mock/MockStateBridge.sol";

contract DeployMockStateBridge is Script {
    MockStateBridge public bridge;

    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public stateBridgeAddress;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        /*//////////////////////////////////////////////////////////////
                                WORLD ID
        //////////////////////////////////////////////////////////////*/
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new MockStateBridge(worldIDIdentityManagerAddress, opWorldIDAddress);

        vm.stopBroadcast();
    }
}
