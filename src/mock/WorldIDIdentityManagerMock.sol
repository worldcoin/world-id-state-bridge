// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IWorldIDIdentityManager} from "src/interfaces/IWorldIDIdentityManager.sol";

/// @title WorldID Identity Manager Mock
/// @author Worldcoin
/// @notice  Mock of the WorldID Identity Manager contract (world-id-contracts) to test functionality on a local chain
/// @dev deployed through make mock and make local-mock
contract WorldIDIdentityManagerMock is IWorldIDIdentityManager {
    uint256 internal _latestRoot;

    constructor(uint256 newRoot) {
        _latestRoot = newRoot;
    }

    function latestRoot() external view returns (uint256) {
        return _latestRoot;
    }
}
