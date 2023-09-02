// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ArbStateBridge} from "src/arbStateBridge.sol";
import {WorldIDIdentityManagerMock} from "src/mock/WorldIDIdentityManagerMock.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";

import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title State Bridge Test
/// @author Worldcoin
/// @notice A test contract for StateBridge.sol
contract ArbStateBridgeTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                        STORAGE CONFIG                       ///
    ///////////////////////////////////////////////////////////////////
    uint256 public mainnetFork;
    string private MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    /// @notice emitted if there is no CrossDomainMessenger contract deployed on the fork
    error invalidCrossDomainMessengerFork();

    ArbStateBridge public arbStateBridge;
    WorldIDIdentityManagerMock public mockWorldID;

    uint32 public opGasLimit;

    address public mockWorldIDAddress;

    address public owner;

    /// @notice The address of the OpWorldID contract on any OP Stack chain
    address public arbWorldIDAddress;

    /// @notice address for OP Stack chain Ethereum mainnet L1CrossDomainMessenger contract
    address public arbInboxAddress;

    uint256 public sampleRoot;

    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emmitted when the ownership transfer of ArbStateBridge is started (OZ Ownable2Step)
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /// @notice Emmitted when the ownership transfer of ArbStateBridge is accepted (OZ Ownable2Step)
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // @notice Emmitted when the the StateBridge sends a root to the OPWorldID contract
    /// @param root The root sent to the OPWorldID contract on the OP Stack chain
    event RootPropagated(uint256 root);

    /// @notice Emmitted when the the StateBridge gives ownership of the OPWorldID contract
    /// to the WorldID Identity Manager contract away
    /// @param previousOwner The previous owner of the OPWorldID contract
    /// @param newOwner The new owner of the OPWorldID contract
    /// @param isLocal Whether the ownership transfer is local (Optimism/OP Stack chain EOA/contract) or an Ethereum EOA or contract
    event OwnershipTransferredOp(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Emmitted when the the StateBridge sets the root history expiry for OpWorldID and PolygonWorldID
    /// @param rootHistoryExpiry The new root history expiry
    event SetRootHistoryExpiry(uint256 rootHistoryExpiry);

    /// @notice Emmitted when the the StateBridge sets the gas limit for sendRootOp
    /// @param _opGasLimit The new opGasLimit for sendRootOp
    event SetGasLimitSendRoot(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the gas limit for SetRootHistoryExpiryt
    /// @param _opGasLimit The new opGasLimit for SetRootHistoryExpirytimism
    event SetGasLimitSetRootHistoryExpiry(uint32 _opGasLimit);

    /// @notice Emmitted when the the StateBridge sets the gas limit for transferOwnershipOp
    /// @param _opGasLimit The new opGasLimit for transferOwnershipOptimism
    event SetGasLimitTransferOwnershipOp(uint32 _opGasLimit);

    ///////////////////////////////////////////////////////////////////
    ///                            ERRORS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Emitted when an attempt is made to renounce ownership.
    error CannotRenounceOwnership();

    function setUp() public {
        /// @notice Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);

        vm.selectFork(mainnetFork);
        /// @notice Roll the fork to a block where both Optimim's and Base's crossDomainMessenger contract is deployed
        /// @notice and the Base crossDomainMessenger ResolvedDelegateProxy target address is initialized
        vm.rollFork(17711915);

        if (block.chainid == 1) {
            arbInboxAddress = address(0x5eF0D09d1E6204141B4d37530808eD19f60FBa35);
        } else {
            revert invalidCrossDomainMessengerFork();
        }

        // inserting mock root
        sampleRoot = uint256(0x111);
        mockWorldID = new WorldIDIdentityManagerMock(sampleRoot);
        mockWorldIDAddress = address(mockWorldID);

        arbWorldIDAddress = address(0x1);

        arbStateBridge = new ArbStateBridge (
            mockWorldIDAddress,
            arbWorldIDAddress,
            arbInboxAddress
        );

        owner = arbStateBridge.owner();
    }

    ///////////////////////////////////////////////////////////////////
    ///                           SUCCEEDS                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice select a specific fork
    function test_canSelectFork_succeeds() public {
        // select the fork
        vm.selectFork(mainnetFork);
        assertEq(vm.activeFork(), mainnetFork);
    }

    function test_propagateRoot_suceeds() public {
        vm.expectEmit(true, true, true, true);
        emit RootPropagated(sampleRoot);

        arbStateBridge.propagateRoot();

        // Bridging is not emulated
    }
}
