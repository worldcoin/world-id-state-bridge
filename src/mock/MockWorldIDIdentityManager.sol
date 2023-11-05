// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IWorldIDIdentityManager} from "src/interfaces/IWorldIDIdentityManager.sol";

/// @title WorldID Identity Manager Mock
/// @author Worldcoin
/// @notice  Mock of the WorldID Identity Manager contract (world-id-contracts) to test functionality on a local chain
/// @dev deployed through make mock and make local-mock
contract MockWorldIDIdentityManager is IWorldIDIdentityManager {
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

    /// @notice Registers identities into the WorldID system.
    /// @dev Can only be called by the identity operator.
    /// @dev Registration is performed off-chain and verified on-chain via the `insertionProof`.
    ///      This saves gas and time over inserting identities one at a time.
    ///
    /// @param insertionProof The proof that given the conditions (`preRoot`, `startIndex` and
    ///        `identityCommitments`), insertion into the tree results in `postRoot`. Elements 0 and
    ///        1 are the `x` and `y` coordinates for `ar` respectively. Elements 2 and 3 are the `x`
    ///        coordinate for `bs`, and elements 4 and 5 are the `y` coordinate for `bs`. Elements 6
    ///        and 7 are the `x` and `y` coordinates for `krs`.
    /// @param preRoot The value for the root of the tree before the `identityCommitments` have been
    ////       inserted. Must be an element of the field `Kr`. (already in reduced form)
    /// @param startIndex The position in the tree at which the insertions were made.
    /// @param identityCommitments The identities that were inserted into the tree starting at
    ///        `startIndex` and `preRoot` to give `postRoot`. All of the commitments must be
    ///        elements of the field `Kr`.
    /// @param postRoot The root obtained after inserting all of `identityCommitments` into the tree
    ///        described by `preRoot`. Must be an element of the field `Kr`. (alread in reduced form)
    ///
    function registerIdentities(
        uint256[8] calldata insertionProof,
        uint256 preRoot,
        uint32 startIndex,
        uint256[] calldata identityCommitments,
        uint256 postRoot
    ) public {
        _latestRoot = postRoot;
        emit TreeChanged(preRoot, TreeChange.Insertion, postRoot);
    }

    /// @notice Deletes identities from the WorldID system.
    /// @dev Can only be called by the identity operator.
    /// @dev Deletion is performed off-chain and verified on-chain via the `deletionProof`.
    ///      This saves gas and time over deleting identities one at a time.
    ///
    /// @param deletionProof The proof that given the conditions (`preRoot` and `packedDeletionIndices`),
    ///        deletion into the tree results in `postRoot`. Elements 0 and 1 are the `x` and `y`
    ///        coordinates for `ar` respectively. Elements 2 and 3 are the `x` coordinate for `bs`,
    ///         and elements 4 and 5 are the `y` coordinate for `bs`. Elements 6 and 7 are the `x`
    ///         and `y` coordinates for `krs`.
    /// @param packedDeletionIndices The indices of the identities that were deleted from the tree. The batch size is inferred from the length of this
    //// array: batchSize = packedDeletionIndices / 4
    /// @param preRoot The value for the root of the tree before the corresponding identity commitments have
    /// been deleted. Must be an element of the field `Kr`.
    /// @param postRoot The root obtained after deleting all of `identityCommitments` into the tree
    ///        described by `preRoot`. Must be an element of the field `Kr`.
    function deleteIdentities(
        uint256[8] calldata deletionProof,
        bytes calldata packedDeletionIndices,
        uint256 preRoot,
        uint256 postRoot
    ) public {
        _latestRoot = postRoot;
        emit TreeChanged(preRoot, TreeChange.Deletion, postRoot);
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
