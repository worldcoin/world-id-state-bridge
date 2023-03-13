// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {WorldIDIdentityManagerImplV1} from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    WorldIDIdentityManagerImplV1 public worldID;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    address public worldIDIdentityManagerAddress =
        abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
    address public stateBridgeAddress =
        abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));

    function run() public {
        vm.startBroadcast(privateKey);

        worldID = WorldIDIdentityManagerImplV1(worldIDIdentityManagerAddress);

        worldID.initialize(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
