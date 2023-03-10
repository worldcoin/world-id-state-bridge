// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "../../src/StateBridge.sol";

/// @notice Initializes the StateBridge contract
contract InitializeStateBridgeGoerli is Script {
    address public opWorldIDAddress;
    address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public immutable crossDomainMessengerAddress;
    address public checkpointManagerAddress;
    address public fxRootAddress;
    address public stateBridgeAddress;
    uint256 public privateKey;

    StateBridge public bridge;

    function setup() public {
        /*//////////////////////////////////////////////////////////////
                                 CONFIG
        //////////////////////////////////////////////////////////////*/
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));
    }

    constructor() {
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
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
