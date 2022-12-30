// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

// no point in unit testing this contract, only integratoin testing matters
contract BridgeTest is PRBTest, StdCheats {
    function setUp() public {
        // solhint-disable-previous-line no-empty-blocks
    }
}
