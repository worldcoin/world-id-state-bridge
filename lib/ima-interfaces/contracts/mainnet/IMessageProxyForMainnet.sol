// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IMessageProxyForMainnet.sol - SKALE Interchain Messaging Agent
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
import "./ICommunityPool.sol";

interface IMessageProxyForMainnet is IMessageProxy {
    function setCommunityPool(ICommunityPool newCommunityPoolAddress) external;
    function setNewHeaderMessageGasCost(uint256 newHeaderMessageGasCost) external;
    function setNewMessageGasCost(uint256 newMessageGasCost) external;
    function pause(string calldata schainName) external;
    function resume(string calldata schainName) external;
    function addReimbursedContract(string memory schainName, address reimbursedContract) external;
    function removeReimbursedContract(string memory schainName, address reimbursedContract) external;
    function messageInProgress() external view returns (bool);
    function isPaused(bytes32 schainHash) external view returns (bool);
    function isReimbursedContract(bytes32 schainHash, address contractAddress) external view returns (bool);
    function getReimbursedContractsLength(bytes32 schainHash) external view returns (uint256);
    function getReimbursedContractsRange(
        bytes32 schainHash,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory contractsInRange);
}