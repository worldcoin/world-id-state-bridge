// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// demo deployments 0x38b421a8A92375A356224F15CDE7AA94F64d371a

import { Script } from "forge-std/Script.sol";
import { DeployStateBridgeBase } from "./DeployStateBridgeBase.s.sol";
import { StateBridge } from "../src/StateBridge.sol";
import { LibRLP } from "./utils/LibRLP.sol";

contract DeployStateBridgeGoerli is DeployStateBridgeBase {
    address public opWorldIDAdress;
    address public semaphoreAddress;
    address public goerliCrossDomainMessengerAddress = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

    constructor() {
        DeployStateBridgeBase(opWorldIDAddress, semaphoreAddress, goerliCrossDomainMessengerAddress);
    }
}
