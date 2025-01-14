// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Deploy State Bridge Optimism
/// @notice forge script to deploy OpStateBridge.sol on Ethereum mainnet
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployOpStateBridgeMainnet is Script {
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
        opCrossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);

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
