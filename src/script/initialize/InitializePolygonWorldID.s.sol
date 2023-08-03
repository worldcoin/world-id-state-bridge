// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Demo deployments
// Goerli 0x09A02586dAf43Ca837b45F34dC2661d642b8Da15
// https://goerli-optimism.etherscan.io/address/0x09a02586daf43ca837b45f34dc2661d642b8da15#code

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
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    function setUp() public {
        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
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
