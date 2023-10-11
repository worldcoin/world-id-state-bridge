// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IWorldIDIdentityManager} from "src/interfaces/IWorldIDIdentityManager.sol";

/// @title WorldID Identity Manager Mock
/// @author Worldcoin
/// @notice  Mock of the WorldID Identity Manager contract (world-id-contracts) to test functionality on a local chain
/// @dev deployed through make mock and make local-mock
contract WorldIDIdentityManagerMock is IWorldIDIdentityManager {
    uint256 internal _latestRoot;

    /// @notice Represents the kind of change that is made to the root of the tree.
    enum TreeChange {
        Insertion,
        Deletion
    }

    /// @notice Emitted when the current root of the tree is updated.
    ///
    /// @param preRoot The value of the tree's root before the update.
    /// @param kind Either "insertion" or "update", the kind of alteration that was made to the
    ///        tree.
    /// @param postRoot The value of the tree's root after the update.
    event TreeChanged(uint256 indexed preRoot, TreeChange indexed kind, uint256 indexed postRoot);

    constructor(uint256 initRoot) {
        _latestRoot = initRoot;
    }

    function insertRoot(uint256 postRoot) public {
        uint256 preRoot = _latestRoot;
        _latestRoot = postRoot;

        emit TreeChanged(preRoot, TreeChange.Insertion, postRoot);
    }

    function latestRoot() external view returns (uint256) {
        return _latestRoot;
    }
}
