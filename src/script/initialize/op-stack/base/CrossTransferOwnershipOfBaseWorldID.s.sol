// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "src/OpWorldID.sol";
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Ownership Transfer of OpWorldID on Base script for mainnet
/// @notice forge script for transferring ownership of OpWorldID to a local (Base Mainnet)
/// or cross-chain (Ethereum mainnet) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract CrossTransferOwnershipOfBaseWorldIDMainnet is Script {
    uint256 public privateKey;

    OpStateBridge public baseStateBridge;
    address public baseStateBridgeAddress;

    address public newOwner;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/src/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        baseStateBridgeAddress =
            abi.decode(vm.parseJson(json, ".baseStateBridgeAddress"), (address));
        newOwner = abi.decode(vm.parseJson(json, ".newOwner"), (address));
    }

    constructor() {
        ///////////////////////////////////////////////////////////////////
        ///                            GOERLI                           ///
        ///////////////////////////////////////////////////////////////////
        baseStateBridge = OpStateBridge(baseStateBridgeAddress);
    }

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on OpStack chain)
        isLocal = false;

        vm.startBroadcast(privateKey);

        baseStateBridge.transferOwnershipOp(newOwner, isLocal);

        vm.stopBroadcast();
    }
}
