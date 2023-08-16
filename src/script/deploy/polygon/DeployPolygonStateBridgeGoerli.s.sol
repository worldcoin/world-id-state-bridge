// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {PolygonStateBridge} from "src/PolygonStateBridge.sol";

/// @title PolygonState Bridge deployment script
/// @notice forge script to deploy StateBridge.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonStateBridgeGoerli is Script {
    PolygonStateBridge public bridge;

    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;

    address public checkpointManagerAddress;
    address public fxRootAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                           POLYGON                           ///
        ///////////////////////////////////////////////////////////////////

        // https://static.matic.network/network/testnet/mumbai/index.json
        // RoootChainManagerProxy
        checkpointManagerAddress = address(0x2890bA17EfE978480615e330ecB65333b880928e);

        // FxRoot
        fxRootAddress = address(0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new PolygonStateBridge (
            checkpointManagerAddress,
            fxRootAddress,
            worldIDIdentityManagerAddress
        );

        bridge.setFxChildTunnel(polygonWorldIDAddress);

        vm.stopBroadcast();
    }
}
