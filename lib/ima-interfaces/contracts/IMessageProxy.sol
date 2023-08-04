// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IMessageProxy.sol - SKALE Interchain Messaging Agent
 *   Copyright (C) 2021-Present SKALE Labs
 *   @author Dmytro Stebaiev
 *
 *   SKALE IMA is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published
 *   by the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   SKALE IMA is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with SKALE IMA.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma solidity >=0.6.10 <0.9.0;


interface IMessageProxy {

    /**
     * @dev Structure that describes message. Should contain sender of message,
     * destination contract on schain that will receiver message,
     * data that contains all needed info about token or ETH.
     */
    struct Message {
        address sender;
        address destinationContract;
        bytes data;
    }

    /**
     * @dev Structure that contains fields for bls signature.
     */
    struct Signature {
        uint256[2] blsSignature;
        uint256 hashA;
        uint256 hashB;
        uint256 counter;
    }

    function addConnectedChain(string calldata schainName) external;
    function postIncomingMessages(
        string calldata fromSchainName,
        uint256 startingCounter,
        Message[] calldata messages,
        Signature calldata sign
    ) external;
    function setNewGasLimit(uint256 newGasLimit) external;
    function registerExtraContractForAll(address extraContract) external;
    function removeExtraContractForAll(address extraContract) external;    
    function removeConnectedChain(string memory schainName) external;
    function postOutgoingMessage(
        bytes32 targetChainHash,
        address targetContract,
        bytes memory data
    ) external;
    function registerExtraContract(string memory chainName, address extraContract) external;
    function removeExtraContract(string memory schainName, address extraContract) external;
    function setVersion(string calldata newVersion) external;
    function isContractRegistered(
        bytes32 schainHash,
        address contractAddress
    ) external view returns (bool);
    function getContractRegisteredLength(bytes32 schainHash) external view returns (uint256);
    function getContractRegisteredRange(
        bytes32 schainHash,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory);
    function getOutgoingMessagesCounter(string calldata targetSchainName) external view returns (uint256);
    function getIncomingMessagesCounter(string calldata fromSchainName) external view returns (uint256);
    function isConnectedChain(string memory schainName) external view returns (bool);
    function getLastOutgoingMessageBlockId(string memory targetSchainName) external view returns (uint);
}