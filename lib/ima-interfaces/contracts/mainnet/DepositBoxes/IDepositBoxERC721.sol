// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IDepositBoxERC721.sol - SKALE Interchain Messaging Agent
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

import "../IDepositBox.sol";


interface IDepositBoxERC721 is IDepositBox {
    function depositERC721(string calldata schainName, address erc721OnMainnet, uint256 tokenId) external;
    function depositERC721Direct(
        string calldata schainName,
        address erc721OnMainnet,
        uint256 tokenId,
        address receiver
    ) external;
    function addERC721TokenByOwner(string calldata schainName, address erc721OnMainnet) external;
    function getFunds(string calldata schainName, address erc721OnMainnet, address receiver, uint tokenId) external;
    function getSchainToERC721(string calldata schainName, address erc721OnMainnet) external view returns (bool);
    function getSchainToAllERC721Length(string calldata schainName) external view returns (uint256);
    function getSchainToAllERC721(
        string calldata schainName,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory);
}