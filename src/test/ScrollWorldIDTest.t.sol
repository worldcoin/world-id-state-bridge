// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @dev using Test from forge-std which is inherited from Optimism's CommonTest.t.sol
import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { ScrollWorldID } from "src/ScrollWorldID.sol";
import { WorldIDBridge } from "src/abstract/WorldIDBridge.sol";
import { SemaphoreTreeDepthValidator } from "src/utils/SemaphoreTreeDepthValidator.sol";
import {AddressAliasHelper} from
    "@eth-optimism/contracts-bedrock/contracts/vendor/AddressAliasHelper.sol";

import { Predeploys } from "@eth-optimism/contracts-bedrock/contracts/libraries/Predeploys.sol";

import { Encoding } from "@eth-optimism/contracts-bedrock/contracts/libraries/Encoding.sol";
import { Hashing } from "@eth-optimism/contracts-bedrock/contracts/libraries/Hashing.sol";
import { Bytes32AddressLib } from "solmate/src/utils/Bytes32AddressLib.sol";

/// @title ScrollWorldIDTest
/// @author xKaizendev
/// @notice A test contract for ScrollWorldID
/// @dev The ScrollWorldID contract is deployed on Scroll and is called by the StateBridge contract.
contract ScrollWorldIDTest is PRBTest, StdCheats {
    ///////////////////////////////////////////////////////////////////
    ///                           WORLD ID                          ///
    ///////////////////////////////////////////////////////////////////

    address public alice = address(0x1111111);
    // @notice The ScrollWorldID contract
    ScrollWorldID internal id;

    // @notice Merkle tree depth
    uint8 internal treeDepth = 16;

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice CrossDomainOwnable3.sol transferOwnership event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, bool isLocal);

    function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(!SemaphoreTreeDepthValidator.validate(actualTreeDepth));
        vm.expectRevert(abi.encodeWithSignature("UnsupportedTreeDepth(uint8)", actualTreeDepth));

        new ScrollWorldID(actualTreeDepth);
    }

    function setup() public {
        /// @notice Initialize the ScrollWorldID contract
        vm.prank(alice);
        id = new ScrollWorldID(treeDepth);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "PolygonWorldID");
    }

    ///////////////////////////////////////////////////////////////////
    ///                            TESTS                            ///
    ///////////////////////////////////////////////////////////////////

     function _switchToCrossDomainOwnership(ScrollWorldID _id) internal {
        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(alice, alice);

        // CrossDomainOwnable3.sol transferOwnership event
        emit OwnershipTransferred(alice, alice, false);

        // CrossDomainOwnable3.sol transferOwnership to crossDomain address (as alice and to alice)
        vm.prank(_id.owner());
        id.transferOwnership({_owner: alice, _isLocal: false});
    }

    
    /// @notice Test that you can insert new root and check if it is valid
    /// @param newRoot The root of the merkle tree after the first update
    function test_receiveVerifyRoot_succeeds(uint256 newRoot) public {
        vm.assume(newRoot != 0);

        _switchToCrossDomainOwnership(id);

        address owner = id.owner();

        vm.warp(block.timestamp + 200);

        vm.prank(AddressAliasHelper.applyL1ToL2Alias(address(L1Messenger)));

        // set the xDomainMsgSender storage slot to the L1Messenger
        
    }
}
