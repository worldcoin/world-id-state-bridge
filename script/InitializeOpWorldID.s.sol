// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../src/OpWorldID.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable opWorldIDAdress;

    uint256 public immutable preRoot;
    uint128 public immutable preRootTimestamp;

    OpWorldID public opWorldID;

    constructor() {
        // tbd
        opWorldIDAdress = address(0x333);
        // tbd
        stateBridgeAddress = address(0x555);
        // tbd
        preRoot = 230102121234;
        // tbd
        preRootTimestamp = 1620000000;
    }

    function run() public {
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(opWorldIDKey);

        opWorldID = OpWorldID(opWorldIDAdress);

        opWorldID.initialize(preRoot, preRootTimestamp);

        vm.stopBroadcast();
    }
}
