// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {IScrollCrossDomainOwnable} from "src/interfaces/IScrollCrossDomainOwnable.sol";

/// @title Ownership Transfer of OpWorldID on Base
/// @notice forge script for transferring ownership of OpWorldID to a local (Base / Base Goerli)
/// or cross-chain (Ethereum / Ethereum goerli) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract LocalTransferOwnershipOfBaseWorldID is Script {
    uint256 public privateKey;

    address public scrollWorldIDAddress;

    address public newOwner;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    uint32 public opGasLimit;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        privateKey = vm.envUint("PRIVATE_KEY");
        scrollWorldIDAddress = vm.envAddress("SCROLL_WORLD_ID");
        newOwner = vm.envAddress("NEW_OWNER");
    }

    constructor() {}

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        bytes memory call =
            abi.encodeCall(IScrollCrossDomainOwnable.transferOwnership, (newOwner, isLocal));

        (bool ok,) = scrollWorldIDAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
