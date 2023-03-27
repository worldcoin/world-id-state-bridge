// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IBridge} from "../interfaces/IBridge.sol";

/// @title OpWorldID
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on Optimism.
/// @dev This contract is deployed on Optimism and is called by the L1 Proxy contract for new root insertions.
contract WorldIDIdentityManagerImplV1 is Initializable {
    address public stateBridge;
    mapping(uint256 => bool) public rootHistory;

    function initialize(address _stateBridge) public virtual {
        stateBridge = _stateBridge;
    }

    function sendRootToStateBridge(uint256 root) public {
        rootHistory[root] = true;

        IBridge(stateBridge).sendRootMultichain(root);
    }

    function checkValidRoot(uint256 root) public view returns (bool) {
        return rootHistory[root];
    }
}
