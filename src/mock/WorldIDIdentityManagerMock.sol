// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IBridge} from "../interfaces/IBridge.sol";

/// @title WorldID Identity Manager Mock
/// @author Worldcoin
/// @notice  Mock of the WorldID Identity Manager contract (world-id-contracts) to test functionality on a local chain
/// @dev deployed through make mock and make local-mock
contract WorldIDIdentityManagerMock is Initializable {
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
        return true;
    }
}
