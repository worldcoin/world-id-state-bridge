// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// Optimism interface for cross domain messaging
import {
    ICrossDomainMessenger
} from "../node_modules/@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

import { IBridge } from "./IBridge.sol";

contract Bridge is IBridge {
    /// @notice The address of the L2 Root contract
    address public optimismAddress;

    // testnet address for L1 Messenger contract
    address public goerliCrossDomainMessengerAddress = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

    /// @notice Sets the addresses for all the WorldID target chains
    /// @param _optimismAddress The address of the Optimism contract that will receive the new root and timestamp
    constructor(address _optimismAddress) {
        optimismAddress = _optimismAddress;
    }

    /// @notice Sends the latest Semaphore root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest Semaphore root.
    /// @param timestamp The Ethereum block timestamp of the latest Semaphore root.
    function sendRootMultichain(uint256 root, uint128 timestamp) external {
        sendRootToOptimism(root, timestamp);
        // add other chains here
    }

    // @notice Sends the latest Semaphore root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest Semaphore root.
    /// @param timestamp The Ethereum block timestamp of the latest Semaphore root.
    function sendRootToOptimism(uint256 root, uint128 timestamp) internal {
        // ICrossDomainMessenger is an interface for the L1 Messenger contract deployed on Goerli address
        ICrossDomainMessenger(goerliCrossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            optimismAddress,
            abi.encodeWithSignature("receiveRoot(uint256, uint128)", root, timestamp),
            1000000
        );
    }
}
