// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { Script } from "forge-std/Script.sol";
import { GnosisStateBridge } from "src/GnosisStateBridge.sol";

/// @title Gnosis State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol
/// @author Laszlo Fazekas (https://github.com/TheBojda)
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployGnosisStateBridge is Script {
    GnosisStateBridge public bridge;

    address public amBridgeAddress;
    address public gnosisWorldIDAddress;
    address public worldIDIdentityManagerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                           GNOSIS                            ///
        ///////////////////////////////////////////////////////////////////

        // AMB contract on Ethereum Mainnet
        amBridgeAddress = abi.decode(vm.parseJson(json, ".ethereumAMBAddress"), (address));

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////

        worldIDIdentityManagerAddress = abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        gnosisWorldIDAddress = abi.decode(vm.parseJson(json, ".gnosisWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);
        bridge = new GnosisStateBridge(worldIDIdentityManagerAddress, gnosisWorldIDAddress, amBridgeAddress);
        vm.stopBroadcast();
    }
}
