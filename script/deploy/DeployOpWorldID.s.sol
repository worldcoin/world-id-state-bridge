// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @dev Demo deployments
/// @custom:deployment Optimism Goerli (420) 0x0ed95bda37cc9c14596adba8bf37fc60e2fd9080
/// @custom:link https://goerli-optimism.etherscan.io/address/0x0ed95bda37cc9c14596adba8bf37fc60e2fd9080
import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";

/// @title OpWorldID deployment script
/// @notice forge script to deploy OpWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployOpWorldID is Script {
    OpWorldID public opWorldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    uint8 public treeDepth = abi.decode(vm.parseJson(json, ".treeDepth"), (uint8));

    function run() external {
        vm.startBroadcast(privateKey);

        opWorldID = new OpWorldID(treeDepth);

        vm.stopBroadcast();
    }
}
