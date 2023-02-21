// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

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
        worldIDIdentityManagerAddress = address(0x206d2C6A7A600BC6bD3A26A8A12DfFb64698C23C);
        opWorldIDAdress = address(0x09A02586dAf43Ca837b45F34dC2661d642b8Da15);
        stateBridgeDeploymentAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        vm.startBroadcast(bridgeKey);

        bridge = StateBridge(stateBridgeDeploymentAddress);

        bridge.initialize(worldIDIdentityManagerAddress, opWorldIDAdress, crossDomainMessengerAddress);

        vm.stopBroadcast();
    }
}
