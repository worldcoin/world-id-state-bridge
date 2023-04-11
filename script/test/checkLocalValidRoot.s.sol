// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {MockOpPolygonWorldID} from "../../src/mock/MockOpPolygonWorldID.sol";

contract CheckLocalValidRoot is Script {
    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    address public opPolygonWorldIDAddress =
        abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));

    uint256 public newRoot = abi.decode(vm.parseJson(json, ".newRoot"), (uint256));
    MockOpPolygonWorldID public opPolygonWorldID = MockOpPolygonWorldID(opPolygonWorldIDAddress);

    function setUp() public {
        vm.label(opPolygonWorldIDAddress, "MockOpPolygonWorldID");
    }

    function run() external {
        vm.startBroadcast(privateKey);

        opPolygonWorldID.checkValidRoot(newRoot);

        vm.stopBroadcast();
    }
}
