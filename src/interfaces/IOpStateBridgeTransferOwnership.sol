pragma solidity ^0.8.15;

/// @title OpStateBridgeTransferOwnership
/// @notice Interface for the StateBridge to transfer ownership
/// of OpWorldID to another contract on L1 or to a OP Stack chain EOA or contract
/// @dev This is a subset of the OpStateBridge contract
abstract contract IOpStateBridgeTransferOwnership {
    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of OpWorldID to another contract on L1 or to a local OP Stack chain EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwnershipOp(address _owner, bool _isLocal) external virtual;
}
