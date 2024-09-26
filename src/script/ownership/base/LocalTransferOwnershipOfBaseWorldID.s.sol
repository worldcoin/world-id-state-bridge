// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Ownership Transfer of OpWorldID on Base
/// @notice forge script for transferring ownership of OpWorldID to a local (Base / Base Goerli)
/// or cross-chain (Ethereum / Ethereum goerli) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract LocalTransferOwnershipOfBaseWorldID is Script {
    uint256 public privateKey;

    address public baseWorldIDAddress;

    address public newOwner;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        privateKey = vm.envUint("PRIVATE_KEY");
        baseWorldIDAddress = vm.envAddress("BASE_WORLD_ID_ADDRESS");
        newOwner = vm.envAddress("NEW_BASE_WORLD_ID_OWNER");
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

        (bool ok,) = baseWorldIDAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
