// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { Bridge } from "../src/Bridge.sol";

contract BridgeScript is Script {
    address private immutable opWorldIDAdress;

    Bridge public bridge;

    constructor(address _opWorldIDAdress) {
        // get deployment address from OpWorldID.t.sol
        opWorldIDAdress = _opWorldIDAdress;
    }

    function run() public {
        uint256 bridgeKey = vm.envUint("BRIDGE_PRIVATE_KEY");

        address bridgeDeployerAddress = vm.addr(bridgeKey);
        address bridgeAddress = LibRLP.computeAddress(bridgeDeployerAddress, 0);

        vm.startBroadcast(bridgeKey);

        bridge = new Bridge(opWorldIDAdress);

        vm.stopBroadcast();
    }
}
