// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {MockBridgedWorldID} from "./MockBridgedWorldID.sol";
import {WorldIDIdentityManagerMock} from "./WorldIDIdentityManagerMock.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";

/// @title Mock State Bridge
/// @author Worldcoin
/// @notice Mock of the StateBridge to test functionality on a local chain
/// @custom:deployment deployed through make local-mock
contract MockStateBridge is Ownable {
    /// @notice WorldIDIdentityManagerMock contract which will hold a mock root
    WorldIDIdentityManagerMock public worldID;

    /// @notice MockBridgedWorldID contract which will receive the root
    MockBridgedWorldID public mockBridgedWorldID;

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice constructor
    constructor() {
        worldID = new WorldIDIdentityManagerMock(uint256(0x111));
        mockBridgedWorldID = new MockBridgedWorldID(uint8(30));
    }

    /// @notice Sends the latest WorldID Identity Manager root to the Bridged WorldID contract.
    /// @dev Calls this method on the L1 Proxy contract to relay roots to WorldID supported chains.
    function propagateRoot() public {
        uint256 latestRoot = worldID.latestRoot();
        _sendRootToMockBridgedWorldID(latestRoot);
    }

    // @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    function _sendRootToMockBridgedWorldID(uint256 root) internal {
        mockBridgedWorldID.receiveRoot(root);
    }
}
