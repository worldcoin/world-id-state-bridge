// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import { PRBTest } from "@prb/test/PRBTest.sol";
import "forge-std/console.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ScrollStateBridge } from "src/ScrollStateBridge.sol";
import { MockWorldIDIdentityManager } from "src/mock/MockWorldIDIdentityManager.sol";
// import logging

import { MockBridgedWorldID } from "src/mock/MockBridgedWorldID.sol";

contract ScrollStateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;

    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    ScrollStateBridge public scrollStateBridge;
    MockWorldIDIdentityManager public mockWorldID;

    uint32 public opGasLimit;

    address public mockWorldIDAddress;

    address public owner;

    /// @notice The address of the OpWorldID contract on any OP Stack chain
    address public opWorldIDAddress;

    /// @notice address for OP Stack chain Ethereum mainnet L1CrossDomainMessenger contract
    address public opCrossDomainMessengerAddress;

    uint256 public sampleRoot;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when the ownership transfer of OpStateBridge is started (OZ Ownable2Step)
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when the ownership transfer of OpStateBridge is accepted (OZ Ownable2Step)
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // @notice Emitted when the the StateBridge sends a root to the OPWorldID contract
    /// @param root The root sent to the OPWorldID contract on the OP Stack chain
    event RootPropagated(uint256 root);

    /// @notice Emitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism/OP Stack chain EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOp(address indexed previousOwner, address indexed newOwner, bool isLocal);

    /// @notice Emitted when the the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emitted when the the StateBridge sets the gas limit for sendRootOp
    /// @param _opGasLimit The new opGasLimit for sendRootOp
    event SetGasLimitPropagateRoot(uint32 _opGasLimit);

    /// @notice Emitted when the the StateBridge sets the gas limit for SetRootHistoryExpiryt
    /// @param _opGasLimit The new opGasLimit for SetRootHistoryExpirytimism
    event SetGasLimitSetRootHistoryExpiry(uint32 _opGasLimit);

    /// @notice Emitted when the the StateBridge sets the gas limit for transferOwnershipOp
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    event SetGasLimitTransferOwnershipOp(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

    /// @notice Emitted when an attempt is made to set the gas limit to zero
    error GasLimitZero();

    /// @notice Emitted when an attempt is made to set the owner to the zero address
    error AddressZero();

    function setUp() public {

        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);


        vm.selectFork(mainnetFork);

        console.log("mainnetFork: %d", block.chainid);


        if (block.chainid == 11155111) {
            opCrossDomainMessengerAddress = address(0x50c7d3e7f7c656493D1D76aaa1a836CedfCBB16A);
        } else {
            revert invalidCrossDomainMessengerFork();
        }

        // inserting mock root
        sampleRoot = uint256(0x111);
        mockWorldID = new MockWorldIDIdentityManager(sampleRoot);
        mockWorldIDAddress = address(mockWorldID);

        opWorldIDAddress = address(0x1);

        scrollStateBridge = new ScrollStateBridge(mockWorldIDAddress, opWorldIDAddress, opCrossDomainMessengerAddress);

        owner = scrollStateBridge.owner();
    }

    function test_canSelectFork_succeeds() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

      function test_propagateRoot_suceeds() public {
        // vm.expectEmit(true, true, true, true);
        // emit RootPropagated(sampleRoot);

        scrollStateBridge.propagateRoot{value:0.0002 ether}();

        // Bridging is not emulated
    }
}
