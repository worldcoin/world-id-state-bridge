// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "src/StateBridge.sol";

/// @title State Bridge Optimism Gas Limit setter
/// @notice forge script to set the correct gas limits for crossDomainMessenger calls to Optimism for the StateBridge
/// @author Worldcoin
/// @dev Can be executed by running `make set-op-gas-limit`
contract SetOpGasLimit is Script {
    StateBridge public bridge;

    address public stateBridgeAddress;

    StateBridge stateBridge;

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
    uint32 public gasLimitSendRootBase =
        abi.decode(vm.parseJson(json, ".gasLimitSendRootBase"), (uint32));
    uint32 public gasLimitSetRootHistoryExpiryBase =
        abi.decode(vm.parseJson(json, ".gasLimitSetRootHistoryExpiryBase"), (uint32));
    uint32 public gasLimitTransferOwnershipBase =
        abi.decode(vm.parseJson(json, ".gasLimitTransferOwnershipBase"), (uint32));

    function setUp() public {
        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));

        stateBridge = StateBridge(stateBridgeAddress);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        stateBridge.setGasLimitSendRootOptimism(gasLimitSendRootOptimism);
        stateBridge.setGasLimitSetRootHistoryExpiryOptimism(gasLimitSetRootHistoryExpiryOptimism);
        stateBridge.setGasLimitTransferOwnershipOptimism(gasLimitTransferOwnershipOptimism);

        stateBridge.setGasLimitSendRootBase(gasLimitSendRootBase);
        stateBridge.setGasLimitSetRootHistoryExpiryBase(gasLimitSetRootHistoryExpiryBase);
        stateBridge.setGasLimitTransferOwnershipBase(gasLimitTransferOwnershipBase);
        vm.stopBroadcast();
    }
}
