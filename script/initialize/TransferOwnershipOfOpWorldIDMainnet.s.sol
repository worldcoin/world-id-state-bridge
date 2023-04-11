// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {ICrossDomainOwnable3} from "../../src/interfaces/ICrossDomainOwnable3.sol";

/// @title Ownership Transfer of OpWorldID script for Mainnet
/// @notice forge script for transferring ownership of OpWorldID to an local (Optimism)
/// or cross-chain (Ethereum) EOA or contract
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract TransferOwnershipOfOpWorldIDMainnet is Script {
    address public stateBridgeAddress;
    address public opWorldIDAddress;
    address public immutable crossDomainMessengerAddress;
    uint256 public privateKey;

    OpWorldID public opWorldID;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            CONFIG                           ///
        ///////////////////////////////////////////////////////////////////
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));
    }

    constructor() {
        ///////////////////////////////////////////////////////////////////
        ///                           MAINNET                           ///
        ///////////////////////////////////////////////////////////////////
        crossDomainMessengerAddress = address(0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1);
    }

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        crossDomainTransferOwnership(stateBridgeAddress, isLocal);

        vm.stopBroadcast();
    }

    function crossDomainTransferOwnership(address newOwner, bool _isLocal) internal {
        bytes memory message;

        message = abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (newOwner, _isLocal));

        // ICrossDomainMessenger is an interface for the L1 Messenger contract deployed on Goerli address
        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            1000000 // within the free gas limit
        );
    }
}
