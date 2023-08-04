// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   ICommunityPool.sol - SKALE Interchain Messaging Agent
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

import "@skalenetwork/skale-manager-interfaces/IContractManager.sol";


import "./ILinker.sol";
import "./IMessageProxyForMainnet.sol";
import "./ITwin.sol";


interface ICommunityPool is ITwin {
    function initialize(
        IContractManager contractManagerOfSkaleManagerValue,
        ILinker linker,
        IMessageProxyForMainnet messageProxyValue
    ) external;
    function refundGasByUser(bytes32 schainHash, address payable node, address user, uint gas) external returns (uint);
    function rechargeUserWallet(string calldata schainName, address user) external payable;
    function withdrawFunds(string calldata schainName, uint amount) external;
    function setMinTransactionGas(uint newMinTransactionGas) external;
    function setMultiplier(uint newMultiplierNumerator, uint newMultiplierDivider) external;
    function refundGasBySchainWallet(
        bytes32 schainHash,
        address payable node,
        uint gas
    ) external returns (bool);
    function getBalance(address user, string calldata schainName) external view returns (uint);
    function checkUserBalance(bytes32 schainHash, address receiver) external view returns (bool);
    function getRecommendedRechargeAmount(bytes32 schainHash, address receiver) external view returns (uint256);
}