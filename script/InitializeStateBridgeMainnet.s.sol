// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { StateBridge } from "../src/StateBridge.sol";

/// @notice Initializes the StateBridge contract
contract InitializeStateBridgeMainnet is Script {
    address public immutable opWorldIDAdress;
    address public immutable semaphoreAddress;
    address public immutable crossDomainMessengerAddress;

    address public immutable stateBridgeDeploymentAddress;

    StateBridge public bridge;

    constructor() {
        // tbd
        semaphoreAddress = address(0x222);
        // tbd
        opWorldIDAdress = address(0x333);
        /// @dev Ethereum mainnet crossDomainMessenger deployment address
        crossDomainMessengerAddress = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;
        // tbd
        stateBridgeDeploymentAddress = address(0x555);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = StateBridge(stateBridgeDeploymentAddress);

        bridge.initialize(semaphoreAddress, opWorldIDAdress, crossDomainMessengerAddress);

        vm.stopBroadcast();
    }
}
