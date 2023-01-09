// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../src/OpWorldID.sol";
import { LibRLP } from "./utils/LibRLP.sol";

// Optimism Goerli Testnet ChainID = 420

contract OpWorldIDScript is Script {
    uint256 private preRoot;
    uint128 private preRootTimestamp;

    OpWorldID public opWorldID;

    event log_string(string);

    constructor(uint256 _preRoot, uint128 _preRootTimestamp) {
        preRoot = _preRoot;
        preRootTimestamp = _preRootTimestamp;
    }

    function run() external {
        preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
        preRootTimestamp = uint128(block.timestamp);

        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        address opWorldIDDeployerAddress = vm.addr(opWorldIDKey);
        address opWorldIDAddress = LibRLP.computeAddress(opWorldIDDeployerAddress, 0);

        vm.startBroadcast(opWorldIDKey);

        opWorldID = new OpWorldID(preRoot, preRootTimestamp);

        vm.stopBroadcast();

        emit log_string(string.concat(string("OpWorldID deployed to: "), string(abi.encodePacked(opWorldIDAddress))));

        vm.writeLine(
            "../.env",
            string.concat(string("OP_WORLDID_ADDRESS="), string(abi.encodePacked(opWorldIDAddress)))
        );
    }
}
