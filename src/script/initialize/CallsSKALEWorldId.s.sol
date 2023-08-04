// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {StateBridge} from "src/StateBridge.sol";
import {SKALEWorldID} from "src/SKALEWorldID.sol";

/// @title Ownership Transfer of OpWorldID script for testnet
/// @notice forge script for transferring ownership of OpWorldID to a local (Optimism Goerli)
/// or cross-chain (Ethereum Goerli) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract CallsSKALEWorldId is Script {
   // address public stateBridgeAddress;
    //address public skaleWorldIDAddress;
    uint256 public privateKey;

    SKALEWorldID public skaleWorldID;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/src/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
       // skaleWorldIDAddress = abi.decode(vm.parseJson(json, ".skaleWorldIDAddress"), (address));
       // stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));
    }

    //constructor() {
    //}

    function run() public {

        vm.startBroadcast(privateKey);
        skaleWorldID = SKALEWorldID(address(0xC9Bf7597AE327B132391Cf3E535d73C7f4582377));
        
        //skaleWorldID.add_remove_chain(true,0x0000050877ed6397218923b67054bfcfd054c0012d0682fe896667859b4dede9,address(0xC9Bf7597AE327B132391Cf3E535d73C7f4582377));
        //skaleWorldID.GetChainName(0);
        vm.stopBroadcast();
    }
}
