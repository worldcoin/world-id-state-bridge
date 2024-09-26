// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";

/// @title MockBridgedWorldID deployment script
/// @notice forge script to deploy MockBridgedWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make local-mock`.
contract DeployMockBridgedWorldID is Script {
    MockBridgedWorldID public mockBridgedWorldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    uint8 public treeDepth = uint8(vm.envUint("TREE_DEPTH"));

    function run() external {
        vm.startBroadcast(privateKey);

        mockBridgedWorldID = new MockBridgedWorldID(treeDepth);

        vm.stopBroadcast();
    }
}
