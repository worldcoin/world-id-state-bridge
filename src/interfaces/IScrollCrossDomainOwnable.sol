pragma solidity ^0.8.15;

/// @title Optimism - ScrollCrossDomainOwnable Interface
/// @author Worldcoin
/// @notice Interface for the CrossDomainOwnable contract for the Scroll L2
/// @dev Adds functionality to the StateBridge to transfer ownership
/// of ScrollWorldID to another contract on L1 or to a local Scroll EOA or contract
/// @custom:usage abi.encodeCall(IScrollCrossDomainOwnable.transferOwnership, (_owner, _isLocal));
interface IScrollCrossDomainOwnable {
    /// @notice transfers owner to a cross-domain or local owner
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwnership(address _owner, bool _isLocal) external;
}
