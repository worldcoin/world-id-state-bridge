// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x09A02586dAf43Ca837b45F34dC2661d642b8Da15
// https://goerli-optimism.etherscan.io/address/0x09a02586daf43ca837b45f34dc2661d642b8da15#code

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";

// Optimism Goerli Testnet ChainID = 420

contract DeployOpWorldID is Script {
    OpWorldID public opWorldID;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function run() external {
        vm.startBroadcast(privateKey);

        opWorldID = new OpWorldID();

        vm.stopBroadcast();
    }
}
