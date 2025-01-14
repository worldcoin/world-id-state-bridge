// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Base State Bridge deployment script
/// @notice forge script to deploy OpStateBridge.sol on Base
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployBaseStateBridgeSepolia is Script {
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
        baseCrossDomainMessengerAddress = address(0xC34855F4De64F1840e5686e64278da901e261f20);

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
