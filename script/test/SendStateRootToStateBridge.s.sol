// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {WorldIDIdentityManagerImplV1} from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract SendStateRootToStateBridge is Script {
    address public worldIDAddress;
    uint256 public newRoot;

    WorldIDIdentityManagerImplV1 public worldID;

    uint256 privateKey;

    function setup() public {
        /*//////////////////////////////////////////////////////////////
                                 CONFIG
        //////////////////////////////////////////////////////////////*/
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

        worldIDAddress = abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        newRoot = abi.decode(vm.parseJson(json, ".newRoot"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        worldID = WorldIDIdentityManagerImplV1(worldIDAddress);

        worldID.sendRootToStateBridge(newRoot);

        vm.stopBroadcast();
    }
}
