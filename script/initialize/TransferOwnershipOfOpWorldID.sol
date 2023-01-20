// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { OpWorldID } from "../../src/OpWorldID.sol";

/// @notice Initializes the StateBridge contract
contract TransferOwnershipOfOpWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable opWorldIDAdress;

    OpWorldID public opWorldID;

    constructor() {
        opWorldIDAdress = address(0xEe6abb338938740f7292aAd2a1c440239792b510);
        stateBridgeAddress = address(0x6de5BC2B62815D85b4A8fe6BE3ed17f5b4E61c73);
    }

    function run() public {
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(opWorldIDKey);

        opWorldID = OpWorldID(opWorldIDAdress);

        opWorldID.transferOwnership(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
