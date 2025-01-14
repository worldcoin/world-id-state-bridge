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
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    ///////////////////////////////////////////////////////////////////
    ///                        OP GAS LIMITS                        ///
    ///////////////////////////////////////////////////////////////////
    uint32 public gasLimitSendRootOptimism =
        abi.decode(vm.parseJson(json, ".gasLimitSendRootOptimism"), (uint32));
    uint32 public gasLimitSetRootHistoryExpiryOptimism =
        abi.decode(vm.parseJson(json, ".gasLimitSetRootHistoryExpiryOptimism"), (uint32));
    uint32 public gasLimitTransferOwnershipOptimism =
        abi.decode(vm.parseJson(json, ".gasLimitTransferOwnershipOptimism"), (uint32));

    function setUp() public {
        optimismStateBridgeAddress =
            abi.decode(vm.parseJson(json, ".optimismStateBridgeAddress"), (address));

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
