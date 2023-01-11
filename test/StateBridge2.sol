// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// Optimism interface for cross domain messaging
import { ICrossDomainMessenger } from "@eth-optimism/contracts-bedrock/contracts/L1/L1CrossDomainMessenger.sol";
import { IBridge } from "./interfaces/IBridge.sol";
import { Initializable } from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";

contract StateBridge is IBridge, Initializable, UUPSUpgradeable {
    /// @notice The owner of the contract
    address public owner;

    /// @notice The address of the OPWorldID contract on Optimism
    address public optimismAddress;

    /// @notice testnet address for L1 Messenger contract (TBD for Testnet Optimism-Bedrock)
    address public crossDomainMessengerAddress;

    /// @notice test counter
    uint256 internal counter;

    /// @notice Sets the addresses for all the WorldID target chains
    /// @param _optimismAddress The address of the Optimism contract that will receive the new root and timestamp
    function initialize(address _optimismAddress) public virtual initializer {
        owner = msg.sender;
        optimismAddress = _optimismAddress;
        counter = 420;
    }

    /// @notice Sends the latest Semaphore root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest Semaphore root.
    /// @param timestamp The Ethereum block timestamp of the latest Semaphore root.
    function sendRootMultichain(uint256 root, uint128 timestamp) external {
        _sendRootToOptimism(root, timestamp);
        // add other chains here
    }

    // @notice Sends the latest Semaphore root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest Semaphore root.
    /// @param timestamp The Ethereum block timestamp of the latest Semaphore root.
    function _sendRootToOptimism(uint256 root, uint128 timestamp) internal {
        bytes memory message;

        message = abi.encodeWithSignature("receiveRoot(uint256, uint128)", root, timestamp);

        // ICrossDomainMessenger is an interface for the L1 Messenger contract deployed on Goerli address
        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            optimismAddress,
            message,
            1000000 // within the free gas limit
        );
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }

    error Unauthorized();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner;
}
