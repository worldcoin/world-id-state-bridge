// SPDX-License-Identifier: MIT
pragma solidity >0.5.0 <0.9.0;

/**
 * @title ICrossDomainMessenger
 * @dev Vendored from @eth-optimism/contracts v0.6.0
 */
interface ICrossDomainMessenger {
    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit
    );
    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);

    function xDomainMessageSender() external view returns (address);

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    function sendMessage(address _target, bytes calldata _message, uint32 _gasLimit) external;
}
