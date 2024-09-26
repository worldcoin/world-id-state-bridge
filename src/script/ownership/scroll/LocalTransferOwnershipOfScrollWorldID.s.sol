// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {IScrollCrossDomainOwnable} from "src/interfaces/IScrollCrossDomainOwnable.sol";

/// @title Ownership Transfer of ScrollWorldID on Scroll
/// @notice forge script for transferring ownership of ScrollWorldID to a local (Scroll / Scroll Sepolia)
/// or cross-chain (Ethereum / Ethereum Sepolia) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract LocalTransferOwnershipOfScrollWorldID is Script {
    uint256 public privateKey;

    address public scrollWorldIDAddress;

    address public newOwner;

    /// @notice in ScrollCrossDomainOwnable.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the ScrollMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        privateKey = vm.envUint("PRIVATE_KEY");
        newOwner = vm.envAddress("NEW_SCROLL_WORLD_ID_OWNER");
        scrollWorldIDAddress = vm.envAddress("SCROLL_WORLD_ID_ADDRESS");
    }

    constructor() {}

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Scroll)
        isLocal = false;

        vm.startBroadcast(privateKey);

        bytes memory call =
            abi.encodeCall(IScrollCrossDomainOwnable.transferOwnership, (newOwner, isLocal));

        (bool ok,) = scrollWorldIDAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
