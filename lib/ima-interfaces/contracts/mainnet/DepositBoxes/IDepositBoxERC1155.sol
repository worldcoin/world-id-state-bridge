// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IDepositBoxERC1155.sol - SKALE Interchain Messaging Agent
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


interface IDepositBoxERC1155 is IDepositBox {
    function depositERC1155(string calldata schainName, address erc1155OnMainnet, uint256 id, uint256 amount) external;
    function depositERC1155Direct(
        string calldata schainName,
        address erc1155OnMainnet,
        uint256 id,
        uint256 amount,
        address receiver
    ) external;
    function depositERC1155Batch(
        string calldata schainName,
        address erc1155OnMainnet,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
    function depositERC1155BatchDirect(
        string calldata schainName,
        address erc1155OnMainnet,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        address receiver
    ) external;
    function addERC1155TokenByOwner(string calldata schainName, address erc1155OnMainnet) external;
    function getFunds(
        string calldata schainName,
        address erc1155OnMainnet,
        address receiver,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;
    function getSchainToERC1155(string calldata schainName, address erc1155OnMainnet) external view returns (bool);
    function getSchainToAllERC1155Length(string calldata schainName) external view returns (uint256);
    function getSchainToAllERC1155(
        string calldata schainName,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory);
}