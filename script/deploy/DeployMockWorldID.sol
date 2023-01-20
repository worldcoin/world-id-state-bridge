// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { WorldIDIdentityManagerImplV1 } from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

// Optimism Goerli Testnet ChainID = 420

contract DeployMockWorldID is Script {
    WorldIDIdentityManagerImplV1 public worldID;

    function run() external {
        uint256 worldIDKey = vm.envUint("WORLDID_PRIVATE_KEY");

        vm.startBroadcast(worldIDKey);

        worldID = new WorldIDIdentityManagerImplV1();

        vm.stopBroadcast();
    }
}
