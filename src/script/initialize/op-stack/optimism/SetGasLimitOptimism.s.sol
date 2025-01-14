// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Optimism State Bridge Gas Limit setter
/// @notice forge script to set the correct gas limits for crossDomainMessenger calls to Optimism for the StateBridge
/// @author Worldcoin
/// @dev Can be executed by running `make set-op-gas-limit`
contract SetOpGasLimitOptimism is Script {
    address public optimismStateBridgeAddress;

    OpStateBridge public optimismStateBridge;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    ///////////////////////////////////////////////////////////////////
    ///                        OP GAS LIMITS                        ///
    ///////////////////////////////////////////////////////////////////
    uint32 public gasLimitSendRootOptimism = uint32(vm.envUint("GAS_LIMIT_SEND_ROOT_OPTIMISM"));
    uint32 public gasLimitSetRootHistoryExpiryOptimism =
        uint32(vm.envUint("GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY_OPTIMISM"));
    uint32 public gasLimitTransferOwnershipOptimism =
        uint32(vm.envUint("GAS_LIMIT_TRANSFER_OWNERSHIP_OPTIMISM"));

    function setUp() public {
        optimismStateBridgeAddress = vm.envAddress("OPTIMISM_STATE_BRIDGE_ADDRESS");

        optimismStateBridge = OpStateBridge(optimismStateBridgeAddress);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        optimismStateBridge.setGasLimitPropagateRoot(gasLimitSendRootOptimism);
        optimismStateBridge.setGasLimitSetRootHistoryExpiry(gasLimitSetRootHistoryExpiryOptimism);
        optimismStateBridge.setGasLimitTransferOwnershipOp(gasLimitTransferOwnershipOptimism);

        vm.stopBroadcast();
    }
}
