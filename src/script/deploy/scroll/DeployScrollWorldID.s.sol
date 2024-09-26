// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ScrollWorldID} from "src/ScrollWorldID.sol";

/// @title Scroll World ID deployment script
/// @notice forge script to deploy ScrollWorldID.sol to Scroll
/// @author Worldcoin
contract DeployScrollWorldID is Script {
    ScrollWorldID public scrollWorldID;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    uint8 public treeDepth = uint8(30);
    // L2ScrollMessenger address on Sepolia
    address scrollMessengerAddress = address(0xBa50f5340FB9F3Bd074bD638c9BE13eCB36E603d);

    function run() external {
        vm.startBroadcast(privateKey);

        scrollWorldID = new ScrollWorldID(treeDepth, scrollMessengerAddress);

        vm.stopBroadcast();
    }
}
