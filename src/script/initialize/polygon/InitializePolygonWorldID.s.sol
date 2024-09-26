// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Demo deployments

import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "src/PolygonWorldID.sol";

contract InitializePolygonWorldID is Script {
    address public stateBridgeAddress;
    address public polygonWorldIDAddress;

    // Polygon PoS Mumbai Testnet Child Tunnel
    address public fxChildAddress = address(0xCf73231F28B7331BBe3124B907840A94851f9f11);

    PolygonWorldID public polygonWorldID;
    uint256 public privateKey;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        stateBridgeAddress = vm.envAddress("POLYGON_STATE_BRIDGE_ADDRESS");
        polygonWorldIDAddress = vm.envAddress("POLYGON_WORLD_ID_ADDRESS");
    }

    // Polygon PoS Mainnet Child Tunnel
    // address fxChildAddress = address(0x8397259c983751DAf40400790063935a11afa28a);

    function run() external {
        vm.startBroadcast(privateKey);

        polygonWorldID = PolygonWorldID(polygonWorldIDAddress);

        polygonWorldID.setFxRootTunnel(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
