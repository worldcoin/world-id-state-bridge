// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {IWorldID} from "../../src/interfaces/IWorldID.sol";
import {console2} from "forge-std/console2.sol";

/// @notice Sends the a WorldID state root to the state bridge
contract SendStateRootToStateBridge is Script {
    address public worldIDAddress;
    uint256 public newRoot;

    IWorldID public worldID;

    uint256 public privateKey;

    function setUp() public {
        /*//////////////////////////////////////////////////////////////
                                 CONFIG
        //////////////////////////////////////////////////////////////*/
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        worldIDAddress = abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        newRoot = abi.decode(vm.parseJson(json, ".newRoot"), (uint256));

        vm.label(worldIDAddress, "WorldIDIdentityManagerImplV1");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        worldID = IWorldID(worldIDAddress);

        worldID.sendRootToStateBridge(newRoot);

        vm.stopBroadcast();
    }
}
