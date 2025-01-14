// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {PolygonStateBridge} from "src/PolygonStateBridge.sol";

/// @title PolygonState Bridge deployment script
/// @notice forge script to deploy StateBridge.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonStateBridgeSepolia is Script {
    PolygonStateBridge public bridge;

    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;

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

        // https://github.com/0xPolygon/static/blob/master/network/testnet/amoy/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0x34F5A25B627f50Bb3f5cAb72807c4D4F405a9232);

        // FxRoot
        fxRootAddress = address(0x0E13EBEdDb8cf9f5987512d5E081FdC2F5b0991e);

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
