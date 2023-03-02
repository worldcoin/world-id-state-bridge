// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// Optimism interface for cross domain messaging
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {IBridge} from "src/interfaces/IBridge.sol";
import {IWorldIDIdentityManager} from "src/interfaces/IWorldIDIdentityManager.sol";
import {Initializable} from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/proxy/utils/UUPSUpgradeable.sol";

contract StateBridge2 is IBridge, Initializable, UUPSUpgradeable {
    /// @notice The owner of the contract
    address public owner;

    /// @notice The address of the OPWorldID contract on Optimism
    address public opWorldIDAddress;

    /// @notice testnet address for L1 Messenger contract (TBD for Testnet Optimism-Bedrock)
    address public crossDomainMessengerAddress;

    /// @notice Interface for checkValidRoot within the WorldID Identity Manager contract
    IWorldIDIdentityManager public worldID;

    uint256 counter;

    /// @notice Emmited when the root is not a valid root in the canonical WorldID Identity Manager contract
    error InvalidRoot();

    /// @notice Emmited when the sender is not the owner of the contract
    error Unauthorized();

    /// @notice Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    /// @notice Sets the addresses for all the WorldID target chains
    /// @param _worldIDIdentityManager Deployment address of the WorldID Identity Manager contract
    /// @param _opWorldIDAddress Address of the Optimism contract that will receive the new root and timestamp
    /// @param _crossDomainMessenger Deployment of the CrossDomainMessenger contract
    function initialize(
        address _worldIDIdentityManager,
        address _opWorldIDAddress,
        address _crossDomainMessenger
    ) public virtual reinitializer(2) {
        owner = msg.sender;
        opWorldIDAddress = _opWorldIDAddress;
        worldID = IWorldIDIdentityManager(_worldIDIdentityManager);
        crossDomainMessengerAddress = _crossDomainMessenger;
        counter = 420;
    }

    /// @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    function sendRootMultichain(uint256 root) external {
        // If the root is not a valid root in the canonical WorldID Identity Manager contract, revert
        // comment out for mock deployments
        // if (!worldID.checkValidRoot(root)) revert InvalidRoot();

        uint128 timestamp = uint128(block.timestamp);
        _sendRootToOptimism(root, timestamp);
        // add other chains here
    }

    // @notice Sends the latest WorldID Identity Manager root to all chains.
    /// @dev Calls this method on the L1 Proxy contract to relay roots and timestamps to WorldID supported chains.
    /// @param root The latest WorldID Identity Manager root.
    /// @param timestamp The Ethereum block timestamp of the latest WorldID Identity Manager root.
    function _sendRootToOptimism(uint256 root, uint128 timestamp) internal {
        bytes memory message;

        message = abi.encodeWithSignature("receiveRoot(uint256, uint128)", root, timestamp);

        // ICrossDomainMessenger is an interface for the L1 Messenger contract deployed on Goerli address
        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAddress,
            message,
            1000000 // within the free gas limit
        );
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}
}
