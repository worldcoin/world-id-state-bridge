// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../src/OpWorldID.sol";

// Optimism Goerli Testnet ChainID = 420

contract OpWorldIDScript is Script {
    uint256 private immutable preRoot;
    uint128 private immutable preRootTimestamp;

    OpWorldID public opWorldID;

    constructor(uint256 _preRoot, uint128 _preRootTimestamp) {
        preRoot = _preRoot;
        preRootTimestamp = _preRootTimestamp;
    }

    function run() public {
        preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
        preRootTimestamp = uint128(block.timestamp);

        vm.startBroadcast();

        OpWorldID = new OpWorldID(preRoot, preRootTimestamp);

        vm.stopBroadcast();
    }
}
