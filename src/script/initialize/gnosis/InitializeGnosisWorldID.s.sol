// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { Script } from "forge-std/Script.sol";
import { GnosisWorldID } from "src/GnosisWorldID.sol";

contract InitializeGnosisWorldID is Script {
    address public stateBridgeAddress;
    address public gnosisWorldIDAddress;

    GnosisWorldID public gnosisWorldID;
    uint256 public privateKey;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    function setUp() public {
        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

        stateBridgeAddress = abi.decode(vm.parseJson(json, ".gnosisStateBridgeAddress"), (address));
        gnosisWorldIDAddress = abi.decode(vm.parseJson(json, ".gnosisWorldIDAddress"), (address));
    }

    function run() external {
        vm.startBroadcast(privateKey);

        gnosisWorldID = GnosisWorldID(gnosisWorldIDAddress);

        gnosisWorldID.setTrustedSender(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
