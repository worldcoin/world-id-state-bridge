// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

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
    string public path = string.concat(root, "/src/script.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        /*//////////////////////////////////////////////////////////////
                                POLYGON
        //////////////////////////////////////////////////////////////*/

        // https://static.matic.network/network/testnet/mumbai/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0x2890bA17EfE978480615e330ecB65333b880928e);

        // FxRoot
        fxRootAddress = address(0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA);

        /*//////////////////////////////////////////////////////////////
                                OPTIMISM
        //////////////////////////////////////////////////////////////*/
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);

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

        bridge = new StateBridge(
            checkpointManagerAddress,
            fxRootAddress,
            worldIDIdentityManagerAddress,
            opWorldIDAddress,
            crossDomainMessengerAddress
        );

        bridge.setFxChildTunnel(polygonWorldIDAddress);

        vm.stopBroadcast();
    }
}
