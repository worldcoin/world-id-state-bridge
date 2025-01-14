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
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    ///////////////////////////////////////////////////////////////////
    ///                        OP GAS LIMITS                        ///
    ///////////////////////////////////////////////////////////////////
    uint32 public gasLimitSendRootBase =
        abi.decode(vm.parseJson(json, ".gasLimitSendRootBase"), (uint32));
    uint32 public gasLimitSetRootHistoryExpiryBase =
        abi.decode(vm.parseJson(json, ".gasLimitSetRootHistoryExpiryBase"), (uint32));
    uint32 public gasLimitTransferOwnershipBase =
        abi.decode(vm.parseJson(json, ".gasLimitTransferOwnershipBase"), (uint32));

    function setUp() public {
        baseStateBridgeAddress =
            abi.decode(vm.parseJson(json, ".baseStateBridgeAddress"), (address));

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
