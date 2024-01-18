// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {ScrollWorldID} from "src/ScrollWorldID.sol";
import {IScrollCrossDomainOwnable} from "src/interfaces/IScrollCrossDomainOwnable.sol";
import {IScrollStateBridgeTransferOwnership} from
    "src/interfaces/IScrollStateBridgeTransferOwnership.sol";

/// @title Ownership Transfer of World ID on Scroll script
/// @author Worldcoin
contract CrossTransferOwnershipOfScrollWorldID is Script {
    /// @notice in ScrollCrossDomainOwnable.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the ScrollMessenger to pass messages)
    bool public isLocal;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    address public scrollStateBridgeAddress = vm.envAddress("SCROLL_STATE_BRIDGE");
    address public newOwner = vm.envAddress("NEW_OWNER");

    constructor() {}

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        bytes memory call = abi.encodeCall(
            IScrollStateBridgeTransferOwnership.transferOwnershipScroll, (newOwner, isLocal)
        );

        (bool ok,) = scrollStateBridgeAddress.call(call);

        require(ok, "call failed");

        vm.stopBroadcast();
    }
}
