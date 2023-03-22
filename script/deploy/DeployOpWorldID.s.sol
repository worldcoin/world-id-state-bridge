// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x09A02586dAf43Ca837b45F34dC2661d642b8Da15
// https://goerli-optimism.etherscan.io/address/0x09a02586daf43ca837b45f34dc2661d642b8da15#code

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";

// Optimism Goerli Testnet ChainID = 420

contract DeployOpWorldID is Script {
    // TODO: Fetch the latest preRoot and preRootTimestamp from the WorldIDIdentityManagerV1 contract
    uint256 public immutable preRoot = 0x22222;
    uint128 public immutable preRootTimestamp = 0x33333;

    OpWorldID public opWorldID;

    function run() external {
        uint8 treeDepth = uint8(vm.envUint("TREE_DEPTH"));
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(opWorldIDKey);

        opWorldID = new OpWorldID(treeDepth, preRoot, preRootTimestamp);

        vm.stopBroadcast();
    }
}
