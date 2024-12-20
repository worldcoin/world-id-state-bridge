pragma solidity ^0.8.15;

/// @title Interface for the Gnosis AMB Sender contract
/// @author Laszlo Fazekas (https://github.com/TheBojda)
interface IAMB {
    /// @notice Sends a message to the Arbitrary Message Bridge
    /// @param _contract The address of the contract on the Gnosis chain to send the message to
    /// @param _data The data to send to the contract
    /// @param _gas The amount of gas to send with the message
    function requireToPassMessage(address _contract, bytes calldata _data, uint256 _gas)
        external
        returns (bytes32);

    /// @notice Gives back the address of the message sender on the source chain
    function messageSender() external view returns (address);
}
