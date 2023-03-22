// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {PolygonWorldID} from "src/PolygonWorldID.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title PolygonWorldIDTest
/// @author Worldcoin
/// @notice A test contract for PolygonWorldID
/// @dev The PolygonWorldID contract is deployed on Polygon PoS and is called by the StateBridge contract.
/// @dev This contract uses the Optimism CommonTest.t.sol tool suite to test the PolygonWorldID contract.
contract PolygonWorldIDTest is PRBTest, StdCheats {
    /*//////////////////////////////////////////////////////////////
                                WORLD ID
    //////////////////////////////////////////////////////////////*/
    /// @notice The PolygonWorldID contract
    PolygonWorldID internal id;

    /// @notice The root of the merkle tree after the first update
    uint256 public newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;

    /// @notice The timestamp of the root of the merkle tree after the first update
    uint128 public newRootTimestamp;

    /// @notice demo address
    address public alice = address(0x1111111);

    /// @notice fxChild contract address
    address public fxChild = address(0x2222222);

    bytes public data;

    function setUp() public {
        newRootTimestamp = uint128(block.timestamp + 100);

        data = abi.encode(newRoot, newRootTimestamp);

        /// @notice Initialize the PolygonWorldID contract
        vm.prank(alice);
        id = new PolygonWorldID(fxChild);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "PolygonWorldID");
    }

    /// pending unit tests, hard to test internal functions that depend on Polygon State Bridge functionality
    /// no straightforward way to vm.prank as the Polygon State Bridge (fxChildTunnel)
}
