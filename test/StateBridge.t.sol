// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import { UUPSUpgradeable } from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import { ERC1967Upgrade } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import { ERC1967Proxy } from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { StateBridge } from "../src/StateBridge.sol";
import { StateBridge2 } from "./StateBridge2.sol";
import { StateBridgeProxy } from "../src/StateBridgeProxy.sol";

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

contract StateBridgeTest is PRBTest, StdCheats {
    address public testSemaphoreAddress;
    address public testOptimismAddress;
    address public crossDomainMessengerAddress;

    function setUp() public {
        testSemaphoreAddress = address(0x1234);
        testOptimismAddress = address(0x5678);
        crossDomainMessengerAddress = address(0x9abc);
    }

    function testBridgeUpgrade() public {
        console2.log("testBridgeUpgrade");

        // deploy StateBridge
        StateBridge stateBridge = new StateBridge();

        address stateBridgeAddress = address(stateBridge);

        bytes memory initCallData = abi.encodeCall(
            StateBridge.initialize,
            (testSemaphoreAddress, testOptimismAddress, crossDomainMessengerAddress)
        );

        // deploy StateBridgeProxy
        StateBridgeProxy stateBridgeProxy = new StateBridgeProxy(stateBridgeAddress, initCallData);

        address stateBridgeProxyAddress = address(stateBridgeProxy);

        address newStateBridge = address(new StateBridge2());

        initCallData = abi.encodeCall(
            StateBridge2.initialize,
            (testSemaphoreAddress, testOptimismAddress, crossDomainMessengerAddress)
        );

        (bool success, bytes memory result) = stateBridgeProxyAddress.call(
            abi.encodeCall(
                UUPSUpgradeable.upgradeToAndCall,
                (
                    newStateBridge,
                    abi.encodeCall(
                        StateBridge2.initialize,
                        (testSemaphoreAddress, testOptimismAddress, crossDomainMessengerAddress)
                    )
                )
            )
        );

        assert(success);

        (success, result) = stateBridgeProxyAddress.call(abi.encodeCall(StateBridge2.getCounter, ()));

        assert(success);

        assertEq(abi.decode(result, (uint256)), 420);
    }
}
