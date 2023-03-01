// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import {PolygonWorldID} from "../src/PolygonWorldID.sol";
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

    /// @notice The root of the merkle tree before the first update
    uint256 public preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;

    /// @notice The root of the merkle tree after the first update
    uint256 public newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;

    /// @notice The timestamp of the root of the merkle tree after the first update
    uint128 public newRootTimestamp;

    /// @notice demo address
    address public alice = address(0x1111111);

    /// @notice fxChild contract address
    address public fxChild = address(0x2222222);

    /// @notice state bridge contract address
    address public stateBridgeAddress = address(0x3333333);

    bytes public data;

    function setUp() public {
        /// @notice The timestamp of the root of the merkle tree before the first update
        uint128 preRootTimestamp = uint128(block.timestamp);

        newRootTimestamp = uint128(block.timestamp + 100);

        data = abi.encode(newRoot, newRootTimestamp);

        /// @notice Initialize the PolygonWorldID contract
        vm.prank(alice);
        id = new PolygonWorldID(fxChild, preRoot, preRootTimestamp, stateBridgeAddress);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "PolygonWorldID");
    }

    /// pending unit tests, hard to test internal functions that depend on Polygon State Bridge functionality
    /// no straightforward way to vm.prank as the Polygon State Bridge (fxChildTunnel)
}
