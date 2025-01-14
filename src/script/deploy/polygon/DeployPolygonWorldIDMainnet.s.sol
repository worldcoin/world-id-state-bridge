// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "src/PolygonWorldID.sol";

/// @title PolygonWorldID deployment script on Polygon PoS mainnet
/// @notice forge script to deploy PolygonWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonWorldID is Script {
    address public stateBridgeAddress;

    // Polygon PoS Mainnet Child Tunnel
    // https://github.com/0xPolygon/static/blob/master/network/mainnet/v1/index.json
    address public fxChildAddress = address(0x8397259c983751DAf40400790063935a11afa28a);

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
