// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments

import { Script } from "forge-std/Script.sol";
import { StateBridge } from "../src/StateBridge.sol";

/// @notice Initializes the StateBridge contract
contract InitializeStateBridgeGoerli is Script {
    address public immutable opWorldIDAdress;
    address public immutable worldIDIdentityManagerAddress;
    address public immutable crossDomainMessengerAddress;
    address public immutable stateBridgeDeploymentAddress;

    StateBridge public bridge;

    constructor() {
        // tbd
        worldIDIdentityManagerAddress = address(0x222);
        // tbd
        opWorldIDAdress = address(0x333);
        /// @dev Goerli crossDomainMessenger deployment address
        crossDomainMessengerAddress = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;
        // tbd
        stateBridgeDeploymentAddress = address(0x555);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = StateBridge(stateBridgeDeploymentAddress);

        bridge.initialize(worldIDIdentityManagerAddress, opWorldIDAdress, crossDomainMessengerAddress);

        vm.stopBroadcast();
    }
}
