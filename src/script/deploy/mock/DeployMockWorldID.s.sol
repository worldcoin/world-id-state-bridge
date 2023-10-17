// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @dev Demo deployments
/// @custom:deployment Goerli 0x0a4501cda7d0decb737376f0efbb692b4922bc56
/// @custom:link https://goerli.etherscan.io/address/0x0a4501cda7d0decb737376f0efbb692b4922bc56
import {Script} from "forge-std/Script.sol";
import {MockWorldIDIdentityManager} from "src/mock/MockWorldIDIdentityManager.sol";

/// @title Mock World ID deployment script
/// @notice forge script to deploy MockWorldIDIdentityManager.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock` or `make local-mock`.
contract DeployMockWorldID is Script {
    MockWorldIDIdentityManager public worldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    uint256 public sampleRoot = abi.decode(vm.parseJson(json, ".sampleRoot"), (uint256));

    function run() external {
        vm.startBroadcast(privateKey);

        worldID = new MockWorldIDIdentityManager(sampleRoot);

        vm.stopBroadcast();
    }
}
