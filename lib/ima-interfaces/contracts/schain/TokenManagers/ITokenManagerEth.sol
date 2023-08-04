// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   ITokenManagerEth - SKALE Interchain Messaging Agent
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

import "../tokens/IEthErc20.sol";
import "../ICommunityLocker.sol";
import "../IMessageProxyForSchain.sol";
import "../ITokenManager.sol";
import "../ITokenManagerLinker.sol";


interface ITokenManagerEth is ITokenManager {
    function initialize(
        string memory newChainName,
        IMessageProxyForSchain newMessageProxy,
        ITokenManagerLinker newIMALinker,
        ICommunityLocker newCommunityLocker,
        address newDepositBox,
        IEthErc20 ethErc20Address
    ) external;
    function setEthErc20Address(IEthErc20 newEthErc20Address) external;
    function exitToMain(uint256 amount) external;
}