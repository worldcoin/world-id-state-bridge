// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { WorldIDIdentityManagerImplV1 } from "../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public stateBridgeAddress;
    address public mockWorldIDAddress;

    WorldIDIdentityManagerImplV1 public worldID;

    constructor() {
        // tbd
        stateBridgeAddress = address(0x555);
        // tbd
        mockWorldIDAddress = address(0x333);
    }

    function run() public {
        uint256 worldIDKey = vm.envUint("WORLDID_PRIVATE_KEY");

        vm.startBroadcast(worldIDKey);

        worldID = new WorldIDIdentityManagerImplV1();

        worldID.initialize(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
