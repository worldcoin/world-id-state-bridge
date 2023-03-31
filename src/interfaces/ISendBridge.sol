pragma solidity ^0.8.15;

/// @title Send Bridge Interface
/// @author Worldcoin
/// @notice An interface for contracts that can send roots to state bridges.
interface ISendBridge {
    /// @notice A function that sends a root to the state bridge.
    ///
    /// @param root The root value to send.
    function sendRootToStateBridge(uint256 root) external;
}
