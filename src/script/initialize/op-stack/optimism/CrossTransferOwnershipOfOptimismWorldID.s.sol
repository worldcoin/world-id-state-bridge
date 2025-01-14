// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "src/OpWorldID.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {IOpStateBridgeTransferOwnership} from "src/interfaces/IOpStateBridgeTransferOwnership.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Ownership Transfer of OpWorldID script on Optimism
/// @notice forge script for transferring ownership of OpWorldID to a local (Optimism)
/// or cross-chain (Ethereum) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract CrossTransferOwnershipOfOptimismWorldID is Script {
    uint256 public privateKey;

    address public optimismStateBridgeAddress;

    address public newOwner;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        privateKey = vm.envUint("PRIVATE_KEY");
        optimismStateBridgeAddress = vm.envAddress("OPTIMISM_STATE_BRIDGE_ADDRESS");
        newOwner = vm.envAddress("NEW_OPTIMISM_WORLD_ID_OWNER");
    }

    constructor() {}

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        bytes memory call =
            abi.encodeCall(IOpStateBridgeTransferOwnership.transferOwnershipOp, (newOwner, isLocal));

        (bool ok,) = optimismStateBridgeAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
