// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {WorldIDBridge} from "./abstract/WorldIDBridge.sol";

//import {ISKLALEWorldID} from "./interfaces/ISKLALEWorldID.sol";
import {SemaphoreTreeDepthValidator} from "./utils/SemaphoreTreeDepthValidator.sol";
import {SemaphoreVerifier} from "semaphore/base/SemaphoreVerifier.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {BytesUtils} from "./utils/BytesUtils.sol";
import {IMessageProxy} from "ima-interfaces/IMessageProxy.sol";
import {ISKLALEWorldID} from "./interfaces/ISKLALEWorldID.sol";

contract SKALEWorldID is WorldIDBridge, Ownable {
    
    uint256 private totalChains = 0;

    /// @notice The selector of the `receiveRoot` function.
    bytes4 private receiveRootSelector;

    /// @notice The selector of the `receiveRootHistoryExpiry` function.
    bytes4 private receiveRootHistoryExpirySelector;

    bytes32 public constant MAINNET_HASH = keccak256(abi.encodePacked("Mainnet"));
    bytes32 public constant CHAOS_HASH = keccak256(abi.encodePacked("staging-fast-active-bellatrix"));

    address public constant MESSAGE_PROXY_ADDRESS = address(0xd2AAa00100000000000000000000000000000000);

    bool public isMultichain;

    mapping(uint256 => bytes32) private index_to_schainName;
    mapping(bytes32 => address) private schainsName_to_skaleWorldAddress;
    
    error InvalidMessageSelector(bytes4 selector);

    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract the depth of the associated merkle tree.
    ///
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    constructor(uint8 _treeDepth) WorldIDBridge(_treeDepth) {
        receiveRootSelector = bytes4(keccak256("receiveRoot(uint256,uint128)"));
        receiveRootHistoryExpirySelector = bytes4(keccak256("setRootHistoryExpiry(uint256)"));
    //    isMultichain = _isMutichain;
    }

    modifier onlyMessageProxy() {
        require(msg.sender == address(MESSAGE_PROXY_ADDRESS), "Sender is not a message proxy");
        _;
    }

    modifier onlyMultichainEntry() {
        require(isMultichain, "The chain is not the multchain entry");
        _;
    }

    function setIsMultichain(bool state) public {
        isMultichain =state;
    }

    function postMessage(bytes32 schainHash, address sender, bytes memory message)
        external
        onlyMessageProxy
    {
        require(isMultichain ? schainHash == MAINNET_HASH : schainHash == CHAOS_HASH, "Incorrect name of schain");
        require(owner() == sender, "Incorrect sender contract");

        messageHandler(message);
    }

    function messageHandler(bytes memory message) internal virtual {
        bytes4 selector = bytes4(BytesUtils.substring(message, 0, 4));
        bytes memory payload = BytesUtils.substring(message, 4, message.length - 4);

        if (selector == receiveRootSelector) {
            (uint256 root, uint128 timestamp) = abi.decode(payload, (uint256, uint128));
            _receiveRoot(root, timestamp);

        } else if (selector == receiveRootHistoryExpirySelector) {
            uint256 rootHistoryExpiry = abi.decode(payload, (uint256));
            _setRootHistoryExpiry(rootHistoryExpiry);
        } else {
            revert InvalidMessageSelector(selector);
        }

        if(isMultichain) sendToSchains(message);

    }

    function sendToSchains(bytes memory message) internal 
    {// let's try to deploy

        for (uint256 i = 0; i < totalChains; i++) 
        {
            if(schainsName_to_skaleWorldAddress[index_to_schainName[i]] != address(0))
            {
                IMessageProxy(MESSAGE_PROXY_ADDRESS).postOutgoingMessage(index_to_schainName[i], schainsName_to_skaleWorldAddress[index_to_schainName[i]], message);
            }
        }
    }

    function add_remove_chain(bool isToAdd, bytes32 chainName, address worldIdAddress) external onlyMultichainEntry
    {
        if(isToAdd) {
            index_to_schainName[totalChains] = chainName;
            schainsName_to_skaleWorldAddress[chainName] = worldIdAddress;
            totalChains++;
            //Needs the roots update on the added chain
        }
        else{
            schainsName_to_skaleWorldAddress[chainName] = address(0);
        }
    }

    //For testing
    function GetChainName(uint256 index) public view onlyMultichainEntry returns(bytes32,address) {
        bytes32 val = index_to_schainName[index];
        address addr = schainsName_to_skaleWorldAddress[val];

        return (val,addr);
    }

     /// @notice Placeholder to satisfy WorldIDBridge inheritance
    function setRootHistoryExpiry(uint256) public virtual override {
        revert("SKALEWorldID: Root history expiry should only be set via the state bridge");
    }

}
