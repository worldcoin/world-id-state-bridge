// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IMessageProxyForSchain.sol - SKALE Interchain Messaging Agent
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

import "../IMessageProxy.sol";
import "./IKeyStorage.sol";
import "./ITokenManagerLinker.sol";

interface IMessageProxyForSchain is IMessageProxy {
    struct OutgoingMessageData {
        bytes32 dstChainHash; // destination chain
        uint256 msgCounter; // message counter
        address srcContract; // origin
        address dstContract; // receiver
        bytes data; // payload
    }

    function initialize(IKeyStorage blsKeyStorage, string memory schainName) external;
    function setMinimumReceiverBalance(uint256 balance) external;
    function topUpReceiverBalance(address payable receiver) external;
    function messageInProgress() external view returns (bool);
    function verifyOutgoingMessageData(OutgoingMessageData memory message) external view returns (bool);
    function verifySignature(bytes32 hashedMessage, Signature memory signature) external view returns (bool);
}