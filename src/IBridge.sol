pragma solidity >=0.8.4;

interface IBridge {
    /// @notice Sends the latest Semaphore root to Optimism.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to Optimism
    // using the ICrossICrossDomainMessenger.sol interface.
    /// @param root The latest Semaphore root.
    /// @param timestamp The Ethereum block timestamp of the latest Semaphore root.
    function sendRootToOptimism(uint256 root, uint128 timestamp) external {}
}
