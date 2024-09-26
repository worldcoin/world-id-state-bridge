// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Base State Bridge Gas Limit setter
/// @notice forge script to set the correct gas limits for crossDomainMessenger calls to Base for the StateBridge
/// @author Worldcoin
/// @dev Can be executed by running `make set-base-gas-limit`
contract SetOpGasLimitBase is Script {
    address public baseStateBridgeAddress;

    OpStateBridge public baseStateBridge;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    ///////////////////////////////////////////////////////////////////
    ///                        OP GAS LIMITS                        ///
    ///////////////////////////////////////////////////////////////////
    uint32 public gasLimitSendRootBase = uint32(vm.envUint("GAS_LIMIT_SEND_ROOT_BASE"));
    uint32 public gasLimitSetRootHistoryExpiryBase =
        uint32(vm.envUint("GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_BASE"));
    uint32 public gasLimitTransferOwnershipBase =
        uint32(vm.envUint("GAS_LIMIT_TRANSFER_OWNERSHIP_BASE"));

    function setUp() public {
        baseStateBridgeAddress = vm.envAddress("BASE_STATE_BRIDGE_ADDRESS");

        baseStateBridge = OpStateBridge(baseStateBridgeAddress);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        baseStateBridge.setGasLimitPropagateRoot(gasLimitSendRootBase);
        baseStateBridge.setGasLimitSetRootHistoryExpiry(gasLimitSetRootHistoryExpiryBase);
        baseStateBridge.setGasLimitTransferOwnershipOp(gasLimitTransferOwnershipBase);

        vm.stopBroadcast();
    }
}
