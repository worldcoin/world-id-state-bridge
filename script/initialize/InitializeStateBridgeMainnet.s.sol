// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "../../src/StateBridge.sol";

/// @notice Initializes the StateBridge contract
contract InitializeStateBridgeMainnet is Script {
    address public immutable crossDomainMessengerAddress;
    address public worldIDIdentityManagerAddress;
    address public polygonWorldIDAddress;
    address public opWorldIDAddress;

    address public stateBridgeAddress;

    StateBridge public bridge;

    uint256 public privateKey;

    function setup() public {
        /*//////////////////////////////////////////////////////////////
                                 CONFIG
        //////////////////////////////////////////////////////////////*/
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, "privateKey"), (uint256));
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, "worldIDIdentityManagerAddress"), (address));
        opWorldIDAddress = abi.decode(vm.parseJson(json, "optimismWorldIDAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, "polygonWorldIDAddress"), (address));
        stateBridgeAddress = abi.decode(vm.parseJson(json, "stateBridgeAddress"), (address));
    }

    constructor() {
        /// @dev Ethereum mainnet crossDomainMessenger deployment address
        crossDomainMessengerAddress = 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1;
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = StateBridge(stateBridgeAddress);

        bridge.initialize(
            worldIDIdentityManagerAddress,
            opWorldIDAddress,
            polygonWorldIDAddress,
            crossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
