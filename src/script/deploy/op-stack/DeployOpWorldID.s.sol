// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "src/OpWorldID.sol";

/// @title OpWorldID deployment script
/// @notice forge script to deploy OpWorldID.sol to an OP Stack chain
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployOpWorldID is Script {
    OpWorldID public opWorldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    uint8 public treeDepth = uint8(30);

    function run() external {
        vm.startBroadcast(privateKey);

        opWorldID = new OpWorldID(treeDepth);

        vm.stopBroadcast();
    }
}
