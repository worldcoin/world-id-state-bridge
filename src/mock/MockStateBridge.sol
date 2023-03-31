// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Optimism interface for cross domain messaging
import {MockOpPolygonWorldID} from "./MockOpPolygonWorldID.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {IWorldIDIdentityManager} from "../interfaces/IWorldIDIdentityManager.sol";

contract MockStateBridge is Ownable {
    /// @notice The address of the MockOpPolygonWorldID contract
    address public mockOpPolygonWorldIDAddress;

    /// @notice Interface for checkValidRoot within the WorldID Identity Manager contract
    address public worldIDAddress;

    IWorldIDIdentityManager internal worldID;

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice constructor
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _mockOpPolygonWorldIDAddress Address of the MockOpPolygonWorldID contract for the new root and timestamp
    constructor(address _worldIDIdentityManager, address _mockOpPolygonWorldIDAddress) {
        mockOpPolygonWorldIDAddress = _mockOpPolygonWorldIDAddress;
        worldIDAddress = _worldIDIdentityManager;
        worldID = IWorldIDIdentityManager(_worldIDIdentityManager);
    }

    /// @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    function sendRootMultichain(uint256 root) public {
        // If the root is not a valid root in the canonical WorldID Identity Manager contract, revert
        // comment out for mock deployments

        if (!worldID.checkValidRoot(root)) revert InvalidRoot();

        uint128 timestamp = uint128(block.timestamp);
        _sendRootToMockOpPolygonWorldID(root, timestamp);
    }

    /*//////////////////////////////////////////////////////////////
                                OPTIMISM
    //////////////////////////////////////////////////////////////*/

    // @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    function _sendRootToMockOpPolygonWorldID(uint256 root, uint128 timestamp) internal {
        MockOpPolygonWorldID(mockOpPolygonWorldIDAddress).receiveRoot(root, timestamp);
    }
}
