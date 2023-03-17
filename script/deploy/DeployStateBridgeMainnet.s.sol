// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x8438ba278cF0bf6dc75a844755C7A805BB45984F
// https://goerli.etherscan.io/address/0x8438ba278cf0bf6dc75a844755c7a805bb45984f#code

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "src/StateBridge.sol";

contract DeployStateBridge is Script {
    StateBridge public bridge;

    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public crossDomainMessengerAddress;
    address public stateBridgeAddress;

    address public checkpointManagerAddress;
    address public fxRootAddress;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        /*//////////////////////////////////////////////////////////////
                                POLYGON
        //////////////////////////////////////////////////////////////*/

        // https://static.matic.network/network/mainnet/v1/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);
        // FxRoot
        fxRootAddress = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        /*//////////////////////////////////////////////////////////////
                                OPTIMISM
        //////////////////////////////////////////////////////////////*/
        crossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);

        /*//////////////////////////////////////////////////////////////
                                WORLDID
        //////////////////////////////////////////////////////////////*/
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new StateBridge(
            checkpointManagerAddress,
            fxRootAddress,
            worldIDIdentityManagerAddress,
            opWorldIDAddress,
            crossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
