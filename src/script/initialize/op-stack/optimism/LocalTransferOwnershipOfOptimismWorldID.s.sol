// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Ownership Transfer of OpWorldID script for Optimism
/// @notice forge script for transferring ownership of OpWorldID to a local (Optimism)
/// or cross-chain (Ethereum Goerli) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract LocalTransferOwnershipOfOptimismWorldID is Script {
    uint256 public privateKey;

    address public optimismWorldIDAddress;

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
        optimismWorldIDAddress =
            abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        newOwner = abi.decode(vm.parseJson(json, ".optimismStateBridgeAddress"), (address));
    }

    constructor() {}

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        bytes memory call =
            abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (newOwner, isLocal));

        (bool ok,) = optimismWorldIDAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
