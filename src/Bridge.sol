// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

// Optimism interface for cross domain messaging
import {
    ICrossDomainMessenger
} from "../node_modules/@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";

import { IBridge } from "./IBridge.sol";

contract Bridge is IBridge {
    address crossDomainMessengerAddr = 0x5086d1eEF304eb5284A0f6720f79403b4e9bE294;

    function sendRootToOptimism(uint256 root, uint128 timestamp) external {
        ICrossDomainMessenger(crossDomainMessengerAddr).sendMessage(
            // Contract address on L2
            0x38b421a8A92375A356224F15CDE7AA94F64d371a,
            abi.encodeWithSignature("receiveRoot(uint256, uint128)", root, timestamp),
            1000000
        );
    }
}
