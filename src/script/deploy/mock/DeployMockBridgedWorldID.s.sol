// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";

/// @title MockBridgedWorldID deployment script
/// @notice forge script to deploy MockBridgedWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make local-mock`.
contract DeployMockBridgedWorldID is Script {
    MockBridgedWorldID public mockBridgedWorldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    uint8 public treeDepth = abi.decode(vm.parseJson(json, ".treeDepth"), (uint8));

    function run() external {
        vm.startBroadcast(privateKey);

        mockBridgedWorldID = new MockBridgedWorldID(treeDepth);

        vm.stopBroadcast();
    }
}
