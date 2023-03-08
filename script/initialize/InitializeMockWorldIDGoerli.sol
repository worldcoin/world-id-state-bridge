// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {WorldIDIdentityManagerImplV1} from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public stateBridgeAddress;
    address public mockWorldIDAddress;

    WorldIDIdentityManagerImplV1 public worldID;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, "privateKey"), (uint256));

    constructor() {
        stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        mockWorldIDAddress = address(0x206d2C6A7A600BC6bD3A26A8A12DfFb64698C23C);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        worldID = WorldIDIdentityManagerImplV1(mockWorldIDAddress);

        worldID.initialize(stateBridgeAddress);

        vm.stopBroadcast();
    }
}
