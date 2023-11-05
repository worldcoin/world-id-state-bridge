// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {MockWorldIDIdentityManager} from "src/mock/MockWorldIDIdentityManager.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";
import {MockStateBridge} from "src/mock/MockStateBridge.sol";

/// @title Mock State Bridge deployment script
/// @notice forge script to deploy MockStateBridge.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock` or `make local-mock`.
contract DeployMockStateBridge is Script {
    MockStateBridge public mockStateBridge;
    MockWorldIDIdentityManager public mockWorldID;
    MockBridgedWorldID public mockBridgedWorldID;

    address owner;

    uint8 treeDepth;

    uint256 initialRoot;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {}

    function run() public {
        vm.startBroadcast(privateKey);

        treeDepth = uint8(30);

        initialRoot = uint256(0x111);

        mockBridgedWorldID = new MockBridgedWorldID(treeDepth);
        mockWorldID = new MockWorldIDIdentityManager(initialRoot);
        mockStateBridge = new MockStateBridge(address(mockWorldID), address(mockBridgedWorldID));

        mockStateBridge.propagateRoot();

        vm.stopBroadcast();
    }
}
