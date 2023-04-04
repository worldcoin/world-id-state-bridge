pragma solidity ^0.8.15;

/// @title Optimism - CrossDomainOwnable3 Interface
/// @author Worldcoin
/// @notice Interface for the CrossDomainOwnable contract for the Optimism L2
/// @dev Adds functionality to the StateBridge to transfer ownership
/// of OpWorldID to another contract on L1 or to a local Optimism EOA
/// @custom:usage abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (_owner, _isLocal));
interface ICrossDomainOwnable3 {
    /// @notice transfers owner to a cross-domain or local owner
    /// @param _owner new owner (EOA or contract)
    /// @param _isLocal true if new owner is on Optimism, false if it is a cross-domain owner
    function transferOwnership(address _owner, bool _isLocal) external;
}
