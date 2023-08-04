// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @dev Demo deployments
/// @custom:deployment Optimism Goerli (420) 0x0ed95bda37cc9c14596adba8bf37fc60e2fd9080
/// @custom:link https://goerli-optimism.etherscan.io/address/0x0ed95bda37cc9c14596adba8bf37fc60e2fd9080
import {Script} from "forge-std/Script.sol";
import {SKALEWorldID} from "src/SKALEWorldID.sol";

/// @title chaosWorldID deployment script
/// @notice forge script to deploy chaosWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeploySKALEWorldID is Script {
    SKALEWorldID public skaleWorldID;

    uint256 public privateKey;
    uint8 public treeDepth;
    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);


    function setUp() public {
        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        treeDepth = abi.decode(vm.parseJson(json, ".treeDepth"), (uint8));
    }

    function run() external {
        vm.startBroadcast(privateKey);

        skaleWorldID = new SKALEWorldID(treeDepth);

        vm.stopBroadcast();
    }
}
