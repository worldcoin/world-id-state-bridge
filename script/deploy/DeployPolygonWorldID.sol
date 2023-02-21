// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { PolygonWorldID } from "../../src/PolygonWorldID.sol";

// Optimism Goerli Testnet ChainID = 420

contract DeployPolygonWorldID is Script {
    PolygonWorldID public polygonWorldId;

    address fxChildAddress = address(0x1111);

    function run() external {
        uint256 PolygonWorldIDKey = vm.envUint("POLYGON_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(PolygonWorldIDKey);

        polygonWorldId = new PolygonWorldID(fxChildAddress);

        vm.stopBroadcast();
    }
}
