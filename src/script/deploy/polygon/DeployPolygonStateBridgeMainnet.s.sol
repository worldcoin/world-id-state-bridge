// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {PolygonStateBridge} from "src/PolygonStateBridge.sol";

/// @title Deploy PolygonStateBridge on Mainnet
/// @notice forge script to deploy PolygonStateBridge.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonStateBridgeMainnet is Script {
    PolygonStateBridge public bridge;

    address public worldIDIdentityManagerAddress;
    address public polygonWorldIDAddress;
    address public checkpointManagerAddress;
    address public fxRootAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                           POLYGON                           ///
        ///////////////////////////////////////////////////////////////////

        // https://github.com/0xPolygon/static/blob/master/network/mainnet/v1/index.json
        // RootChainManagerProxy
        checkpointManagerAddress = address(0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287);
        // FxRoot
        fxRootAddress = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        polygonWorldIDAddress = vm.envAddress("POLYGON_WORLD_ID_ADDRESS");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new PolygonStateBridge(
            checkpointManagerAddress, fxRootAddress, worldIDIdentityManagerAddress
        );

        bridge.setFxChildTunnel(polygonWorldIDAddress);

        vm.stopBroadcast();
    }
}
