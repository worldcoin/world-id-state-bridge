// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { Script } from "forge-std/Script.sol";
import { GnosisWorldID } from "src/GnosisWorldID.sol";

/// @title GnosisWorldID deployment script on Gnosis Chiado
/// @notice forge script to deploy GnosisWorldID.sol
/// @author @author Laszlo Fazekas (https://github.com/TheBojda)
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployGnosisWorldID is Script {
    address public stateBridgeAddress;

    // AMB contract on Gnosis
    address public amBridge = abi.decode(vm.parseJson(json, ".gnosisAMBAddress"), (address));

    GnosisWorldID public gnosisWorldId;
    uint256 public privateKey;

    uint8 public treeDepth;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    function setUp() public {
        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        treeDepth = uint8(30);
    }

    function run() external {
        vm.startBroadcast(privateKey);

        gnosisWorldId = new GnosisWorldID(treeDepth, amBridge);

        vm.stopBroadcast();
    }
}
