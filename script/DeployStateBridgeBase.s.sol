// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { StateBridge } from "../src/StateBridge.sol";
import { LibRLP } from "./utils/LibRLP.sol";

contract DeployStateBridgeBase is Script {
    address public immutable opWorldIDAdress;
    address public immutable semaphoreAddress;
    address public immutable crossDomainMessengerAddress;

    StateBridge public bridge;

    constructor(
        address _semaphoreAddress,
        address _opWorldIDAdress,
        address _crossDomainMessengerAddress
    ) {
        semaphoreAddress = _semaphoreAddress;
        // get deployment address from OpWorldID.t.sol
        opWorldIDAdress = _opWorldIDAdress;
        crossDomainMessengerAddress = _crossDomainMessengerAddress;
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        address bridgeDeployerAddress = vm.addr(bridgeKey);
        address bridgeAddress = LibRLP.computeAddress(bridgeDeployerAddress, 0);
        opWorldIDAdress = vm.envAddress("OP_WORLDID_ADDRESS");

        vm.startBroadcast(bridgeKey);

        bridge = new StateBridge();

        bridge.initialize(semaphoreAddress, opWorldIDAdress, crossDomainMessengerAddress);

        vm.stopBroadcast();
    }
}
