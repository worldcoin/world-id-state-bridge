// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Deploy Base State Bridge
/// @notice forge script to deploy OpStateBridge contract for Base
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployBaseStateBridgeMainnet is Script {
    OpStateBridge public bridge;

    address public baseWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public baseCrossDomainMessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                             BASE                            ///
        ///////////////////////////////////////////////////////////////////
        // Taken from https://docs.base.org/base-contracts
        baseCrossDomainMessengerAddress = address(0x866E82a600A1414e583f7F13623F1aC5d58b0Afa);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        baseWorldIDAddress = vm.envAddress("BASE_WORLD_ID_ADDRESS");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new OpStateBridge(
            worldIDIdentityManagerAddress, baseWorldIDAddress, baseCrossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
