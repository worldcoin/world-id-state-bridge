// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";

// Optimism Goerli Testnet ChainID = 420

contract DeployOpWorldID is Script {
    OpWorldID public opWorldID;

    function run() external {
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(opWorldIDKey);

        opWorldID = new OpWorldID();

        vm.stopBroadcast();
    }
}
