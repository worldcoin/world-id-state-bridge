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
        stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        mockWorldIDAddress = address(0x206d2C6A7A600BC6bD3A26A8A12DfFb64698C23C);
    }

    function run() public {
        uint256 worldIDKey = vm.envUint("WORLDID_PRIVATE_KEY");

        vm.startBroadcast(worldIDKey);

        worldID = WorldIDIdentityManagerImplV1(mockWorldIDAddress);

        worldID.initialize(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
