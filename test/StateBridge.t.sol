// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";
import {ERC1967Upgrade} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {StateBridge} from "../src/StateBridge.sol";
import {StateBridge2} from "./StateBridge2.sol";
import {StateBridgeProxy} from "../src/StateBridgeProxy.sol";

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

contract StateBridgeTest is PRBTest, StdCheats {
    address public owner;

    address public optimismAddress = address(0x1234);

    function setUp() public {
        owner = address(this);
        vm.label(owner, "owner");
        vm.label(optimismAddress, "optimismAddress");
    }

    event Upgraded(address indexed implementation);

    function testBridgeUpgrade() public {
        console2.log("testBridgeUpgrade");

        // deploy StateBridge
        address stateBridge = address(new StateBridge());
        // deploy StateBridgeProxy
        address stateBridgeProxy = address(new StateBridgeProxy(stateBridge, abi.encodeCall(stateBridge.initialize, (optimismAddress))));

        address newStateBridge = address(new StateBridge2());

        emit Upgraded(newImpl);
        (success, result) = proxy.call(
            abi.encodeCall(
                UUPSUpgradeable.upgradeToAndCall,
                (newStateBridge, abi.encodeCall(StateBridge2.getCounter, ()))
            )
        );
        assert(success);

        assertEq(abi.decode(result, (uint256)), 420);
}
