// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IL1MessageQueue {
 
    /// @notice Return the amount of ETH should pay for cross domain message.
    /// @param gasLimit Gas limit required to complete the message relay on L2.
    function estimateCrossDomainMessageFee(uint256 gasLimit) external view returns (uint256);

    
}
