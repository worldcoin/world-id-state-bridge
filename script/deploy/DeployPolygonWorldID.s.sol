// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Demo deployments
// Goerli 0x09A02586dAf43Ca837b45F34dC2661d642b8Da15
// https://goerli-optimism.etherscan.io/address/0x09a02586daf43ca837b45f34dc2661d642b8da15#code

import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "../../src/PolygonWorldID.sol";

contract DeployPolygonWorldID is Script {
    PolygonWorldID public polygonWorldId;

    // Polygon PoS Mumbai Testnet Child Tunnel
    address fxChildAddress = address(0xCf73231F28B7331BBe3124B907840A94851f9f11);

    // Polygon PoS Mainnet Child Tunnel
    // address fxChildAddress = address(0x8397259c983751DAf40400790063935a11afa28a);

    function run() external {
        uint256 PolygonWorldIDKey = vm.envUint("POLYGON_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(PolygonWorldIDKey);

        polygonWorldId = new PolygonWorldID(fxChildAddress);

        vm.stopBroadcast();
    }
}
