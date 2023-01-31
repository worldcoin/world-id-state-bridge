// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "../../src/StateBridge.sol";

/// @notice Initializes the StateBridge contract
contract InitializeStateBridgeGoerli is Script {
    address public immutable opWorldIDAdress;
    address public immutable worldIDIdentityManagerAddress;
    address public immutable crossDomainMessengerAddress;
    address public immutable stateBridgeDeploymentAddress;

    StateBridge public bridge;

    constructor() {
        // tbd
        worldIDIdentityManagerAddress = address(0xee5f96E2cdb5A194Cd25F0F29cA06fbcB6d1AdE4);
        // tbd
        opWorldIDAdress = address(0xEe6abb338938740f7292aAd2a1c440239792b510);
        /// @dev Goerli crossDomainMessenger deployment address
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
        // tbd
        stateBridgeDeploymentAddress = address(0x6de5BC2B62815D85b4A8fe6BE3ed17f5b4E61c73);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = StateBridge(stateBridgeDeploymentAddress);

        bridge.initialize(worldIDIdentityManagerAddress, opWorldIDAdress, crossDomainMessengerAddress);

        vm.stopBroadcast();
    }
}
