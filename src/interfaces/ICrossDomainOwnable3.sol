pragma solidity ^0.8.15;

/// @notice Interface for the CrossDomainOwnable contract
/// @dev Adds functionality to the StateBridge to transfer ownership
/// of OpWorldID to another contract on L1 or to a local Optimism EOA
interface ICrossDomainOwnable3 {
    /// @notice transfers owner to a cross-domain or local owner
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwnership(address _owner, bool _isLocal) external;
}
