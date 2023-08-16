// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "src/OpWorldID.sol";
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Ownership Transfer of OpWorldID script for testnet
/// @notice forge script for transferring ownership of OpWorldID to a local (Optimism Goerli)
/// or cross-chain (Ethereum Goerli) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract CrossTransferOwnershipOfOpWorldIDGoerli is Script {
    uint256 public privateKey;

    OpStateBridge public optimismStateBridge;
    address public optimismStateBridgeAddress;

    address public newOwner;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    uint32 public opGasLimit;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/src/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        optimismStateBridgeAddress =
            abi.decode(vm.parseJson(json, ".optimismStateBridgeAddress"), (address));
        newOwner = abi.decode(vm.parseJson(json, ".newOwner"), (address));
    }

    constructor() {
        ///////////////////////////////////////////////////////////////////
        ///                            GOERLI                           ///
        ///////////////////////////////////////////////////////////////////
        optimismStateBridge = OpStateBridge(optimismStateBridgeAddress);
    }

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on OpStack chain)
        isLocal = false;

        vm.startBroadcast(privateKey);

        optimismStateBridge.transferOwnershipOp(newOwner, isLocal);

        vm.stopBroadcast();
    }
}
