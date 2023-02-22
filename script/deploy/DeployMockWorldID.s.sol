// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x206d2C6A7A600BC6bD3A26A8A12DfFb64698C23C
// https://goerli.etherscan.io/address/0x206d2c6a7a600bc6bd3a26a8a12dffb64698c23c#code

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
