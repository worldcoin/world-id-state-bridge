// SPDX-License-Identifier: UNLICENSED
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
    uint32 public opGasLimitSendRootOptimism =
        abi.decode(vm.parseJson(json, ".opGasLimitSendRootOptimism"), (uint32));
    uint32 public opGasLimitSetRootHistoryExpiryOptimism =
        abi.decode(vm.parseJson(json, ".opGasLimitSetRootHistoryExpiryOptimism"), (uint32));
    uint32 public opGasLimitTransferOwnershipOptimism =
        abi.decode(vm.parseJson(json, ".opGasLimitTransferOwnershipOptimism"), (uint32));

    function setUp() public {
        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));

        stateBridge = StateBridge(stateBridgeAddress);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        stateBridge.setOpGasLimitSendRootOptimism(opGasLimitSendRootOptimism);
        stateBridge.setOpGasLimitSetRootHistoryExpiryOptimism(
            opGasLimitSetRootHistoryExpiryOptimism
        );
        stateBridge.setOpGasLimitTransferOwnershipOptimism(opGasLimitTransferOwnershipOptimism);

        vm.stopBroadcast();
    }
}
