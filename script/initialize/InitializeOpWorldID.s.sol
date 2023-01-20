// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../../src/OpWorldID.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable opWorldIDAdress;

    uint256 public immutable preRoot;
    uint128 public immutable preRootTimestamp;

    OpWorldID public opWorldID;

    constructor() {
        // tbd
        opWorldIDAdress = address(0xEe6abb338938740f7292aAd2a1c440239792b510);
        // tbd
        stateBridgeAddress = address(0x6de5BC2B62815D85b4A8fe6BE3ed17f5b4E61c73);
        // tbd
        preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
        // tbd
        preRootTimestamp = uint128(block.timestamp);
    }

    function run() public {
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(opWorldIDKey);

        opWorldID = OpWorldID(opWorldIDAdress);

        opWorldID.initialize(preRoot, preRootTimestamp);

        vm.stopBroadcast();
    }
}
