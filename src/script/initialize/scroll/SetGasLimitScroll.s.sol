// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ScrollStateBridge} from "src/ScrollStateBridge.sol";

/// @title Scroll State Bridge Gas Limit setter
/// @author Worldcoin
contract SetGasLimitScroll is Script {
    ScrollStateBridge public scrollStateBridge;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    address public scrollStateBridgeAddress = vm.envAddress("SCROLL_STATE_BRIDGE_ADDRESS");

    ///////////////////////////////////////////////////////////////////
    ///                      SCROLL GAS LIMITS                      ///
    ///////////////////////////////////////////////////////////////////
    uint32 public gasLimitPropagateRootScroll =
        uint32(vm.envUint("GAS_LIMIT_PROPAGATE_ROOT_SCROLL"));
    uint32 public gasLimitSetRootHistoryExpiryScroll =
        uint32(vm.envUint("GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_SCROLL"));
    uint32 public gasLimitTransferOwnershipScroll =
        uint32(vm.envUint("GAS_LIMIT_TRANSFER_OWNERSHIP_SCROLL"));

    function setUp() public {
        scrollStateBridge = ScrollStateBridge(scrollStateBridgeAddress);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        scrollStateBridge.setGasLimitPropagateRoot(gasLimitPropagateRootScroll);
        scrollStateBridge.setGasLimitSetRootHistoryExpiry(gasLimitSetRootHistoryExpiryScroll);
        scrollStateBridge.setGasLimitTransferOwnershipScroll(gasLimitTransferOwnershipScroll);

        vm.stopBroadcast();
    }
}
