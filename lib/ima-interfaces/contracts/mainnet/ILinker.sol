// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   ILinker.sol - SKALE Interchain Messaging Agent
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

import "./ITwin.sol";


interface ILinker is ITwin {
    function registerMainnetContract(address newMainnetContract) external;
    function removeMainnetContract(address mainnetContract) external;
    function connectSchain(string calldata schainName, address[] calldata schainContracts) external;
    function kill(string calldata schainName) external;
    function disconnectSchain(string calldata schainName) external;
    function isNotKilled(bytes32 schainHash) external view returns (bool);
    function hasMainnetContract(address mainnetContract) external view returns (bool);
    function hasSchain(string calldata schainName) external view returns (bool connected);
}