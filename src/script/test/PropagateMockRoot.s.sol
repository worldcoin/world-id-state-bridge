// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {MockStateBridge} from "src/mock/MockStateBridge.sol";

/// @title Propagate Mock Root test script
/// @author Worldcoin
/// @dev Can be executed by running `make local-mock`.
contract PropagateMockRoot is Script {
    MockStateBridge public bridge;

    address public mockStateBridgeAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        mockStateBridgeAddress =
            abi.decode(vm.parseJson(json, ".mockStateBridgeAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = MockStateBridge(mockStateBridgeAddress);

        bridge.propagateRoot();

        vm.stopBroadcast();
    }
}
