pragma solidity ^0.8.15;

/// @title IScrollStateBridgeTransferOwnership
/// @notice Interface for the StateBridge to transfer ownership
/// of ScrollWorldID to another contract on L1 or to a Scroll EOA or contract
/// @dev This is a subset of the ScrollStateBridge contract
abstract contract IScrollStateBridgeTransferOwnership {
    /// @notice Adds functionality to the StateBridge to transfer ownership
    /// of ScrollWorldID to another contract on L1 or to a Scroll chain EOA
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Scroll, false if it is a cross-domain owner
    function transferOwnershipScroll(address _owner, bool _isLocal) external virtual;
}
