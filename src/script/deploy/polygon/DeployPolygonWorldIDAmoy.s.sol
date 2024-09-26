// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "src/PolygonWorldID.sol";

/// @title PolygonWorldID deployment script on Polygon Amoy
/// @notice forge script to deploy PolygonWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonWorldIDAmoy is Script {
    address public stateBridgeAddress;

    // Polygon PoS Amoy Testnet Child Tunnel
    // https://github.com/0xPolygon/static/blob/master/network/testnet/amoy/index.json
    address public fxChildAddress = address(0xE5930336866d0388f0f745A2d9207C7781047C0f);

    PolygonWorldID public polygonWorldId;
    uint256 public privateKey;

    uint8 public treeDepth;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        treeDepth = uint8(30);
    }

    function run() external {
        vm.startBroadcast(privateKey);

        polygonWorldId = new PolygonWorldID(treeDepth, fxChildAddress);

        vm.stopBroadcast();
    }
}
