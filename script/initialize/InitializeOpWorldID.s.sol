// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable opWorldIDAdress;

    uint256 public immutable preRoot;
    uint128 public immutable preRootTimestamp;

    OpWorldID public opWorldID;

    constructor() {
        opWorldIDAdress = address(0x09A02586dAf43Ca837b45F34dC2661d642b8Da15);
        stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
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
