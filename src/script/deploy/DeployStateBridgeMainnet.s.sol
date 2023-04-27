// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "src/StateBridge.sol";

/// @title PolygonWorldID deployment script on Polygon Mumbai
/// @notice forge script to deploy PolygonWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployStateBridge is Script {
    StateBridge public bridge;

    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public crossDomainMessengerAddress;
    address public stateBridgeAddress;

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

        // https://static.matic.network/network/mainnet/v1/index.json
        // RootChainManagerProxy
        checkpointManagerAddress = address(0x86E4Dc95c7FBdBf52e33D563BbDB00823894C287);
        // FxRoot
        fxRootAddress = address(0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2);

        ///////////////////////////////////////////////////////////////////
        ///                           OPTIMISM                          ///
        ///////////////////////////////////////////////////////////////////
        crossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new StateBridge(
            checkpointManagerAddress,
            fxRootAddress,
            worldIDIdentityManagerAddress,
            opWorldIDAddress,
            crossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
