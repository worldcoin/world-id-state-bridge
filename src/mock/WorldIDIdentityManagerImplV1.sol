// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title OpWorldID
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on Optimism.
/// @dev This contract is deployed on Optimism and is called by the L1 Proxy contract for new root insertions.
contract WorldIDIdentityManagerImplV1 is Initializable {
    address stateBridgeProxy;

    function initialize(address _stateBridgeProxy) public virtual reinitializer(1) {
        stateBridgeProxy = _stateBridgeProxy;
    }

    function sendRootToStateBridge(uint256 root) public {
        (bool success,) = stateBridgeProxy.call(abi.encodeWithSignature("sendRootMultichain(uint256)", root));
        assert(success);
    }
}
