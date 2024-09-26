// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Deploy State Bridge Optimism
/// @notice forge script to deploy OpStateBridge.sol on Ethereum mainnet
/// @author Worldcoin
contract DeployOpStateBridgeDevnet is Script {
    OpStateBridge public bridge;

    address public opWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public opCrossDomainMessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                           OPTIMISM                          ///
        ///////////////////////////////////////////////////////////////////
        opCrossDomainMessengerAddress = address(0x7E75b00FfBF0a4295ab7112F04Fd8255334194BD);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        opWorldIDAddress = vm.envAddress("OPTIMISM_WORLD_ID_ADDRESS");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new OpStateBridge(
            worldIDIdentityManagerAddress, opWorldIDAddress, opCrossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
