// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { WorldIDIdentityManagerImplV1 } from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public stateBridgeAddress;
    address public mockWorldIDAddress;

    WorldIDIdentityManagerImplV1 public worldID;

    constructor() {
        // tbd
        stateBridgeAddress = address(0x6de5BC2B62815D85b4A8fe6BE3ed17f5b4E61c73);
        // tbd
        mockWorldIDAddress = address(0xee5f96E2cdb5A194Cd25F0F29cA06fbcB6d1AdE4);
    }

    function run() public {
        uint256 worldIDKey = vm.envUint("WORLDID_PRIVATE_KEY");

        vm.startBroadcast(worldIDKey);

        worldID = WorldIDIdentityManagerImplV1(mockWorldIDAddress);

        worldID.initialize(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
