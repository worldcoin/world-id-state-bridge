// SPDX-License-Identifier: AGPL-3.0-only

/**
 *   IDepositBoxERC20.sol - SKALE Interchain Messaging Agent
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


interface IDepositBoxERC20 is IDepositBox {
    function addERC20TokenByOwner(string calldata schainName, address erc20OnMainnet) external;
    function depositERC20(string calldata schainName, address erc20OnMainnet, uint256 amount) external;
    function doTransfer(address token, address receiver, uint256 amount) external;
    function escalate(uint256 transferId) external;
    function depositERC20Direct(
        string calldata schainName,
        address erc20OnMainnet,
        uint256 amount,
        address receiver
    ) external;
    function getFunds(string calldata schainName, address erc20OnMainnet, address receiver, uint amount) external;
    function rejectTransfer(uint transferId) external;
    function retrieve() external;
    function retrieveFor(address receiver) external;
    function setArbitrageDuration(string calldata schainName, uint256 delayInSeconds) external;
    function setBigTransferValue(string calldata schainName, address token, uint256 value) external;
    function setBigTransferDelay(string calldata schainName, uint256 delayInSeconds) external;
    function stopTrustingReceiver(string calldata schainName, address receiver) external;
    function trustReceiver(string calldata schainName, address receiver) external;
    function validateTransfer(uint transferId) external;
    function isReceiverTrusted(bytes32 schainHash, address receiver) external view returns (bool);
    function getArbitrageDuration(bytes32 schainHash) external view returns (uint256);
    function getBigTransferThreshold(bytes32 schainHash, address token) external view returns (uint256);
    function getDelayedAmount(address receiver, address token) external view returns (uint256 value);
    function getNextUnlockTimestamp(address receiver, address token) external view returns (uint256 unlockTimestamp);
    function getSchainToERC20(string calldata schainName, address erc20OnMainnet) external view returns (bool);
    function getSchainToAllERC20Length(string calldata schainName) external view returns (uint256);
    function getSchainToAllERC20(
        string calldata schainName,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory);
    function getTimeDelay(bytes32 schainHash) external view returns (uint256);
    function getTrustedReceiver(string calldata schainName, uint256 index) external view returns (address);
    function getTrustedReceiversAmount(bytes32 schainHash) external view returns (uint256);
}