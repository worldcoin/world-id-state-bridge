// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import { OpWorldID } from "../src/OpWorldID.sol";
import { L2CrossDomainMessenger } from "@eth-optimism/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol";
import { CrossDomainOwnable2 } from "@eth-optimism/contracts-bedrock/contracts/L2/CrossDomainOwnable2.sol";
import { Predeploys } from "@eth-optimism/contracts-bedrock/contracts/libraries/Predeploys.sol";
import { Messenger_Initializer } from "@eth-optimism/contracts-bedrock/contracts/test/CommonTest.t.sol";

/// Test contract from
/// https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/contracts/test/CrossDomainOwnable2.t.sol
/// to help prank the L2CrossDomainMessenger
contract XDomainSetter2 is CrossDomainOwnable2, Messenger_Initializer {
    uint256 public value;

    function set(uint256 _value) external onlyOwner {
        value = _value;
    }
}

/// @title OpWorldIDTest
/// @author Worldcoin
/// @notice A test contract for OpWorldID
/// @dev The OpWorldID contract is deployed on Optimism and is called by the L1 Proxy contract.
contract OpWorldIDTest is PRBTest, StdCheats {
    /// @notice Common test helpers (@eth-optimism/contracts-bedrock/contracts/test/CommonTest.t.sol)
    address alice = address(128);
    address bob = address(256);

    XDomainSetter2 internal setter;

    /// @notice The OpWorldID contract
    OpWorldID internal id;

    /// @notice The root of the merkle tree before the first update
    uint256 public preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;

    /// @notice The root of the merkle tree after the first update
    uint256 public newRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;

    /// instantiate the L2CrossDomainMessenger to be able to mock calls from it
    address public messengerAddress;

    function setUp() public {
        super.setUp();
        vm.prank(alice);
        setter = new XDomainSetter2();
        /// @notice The timestamp of the root of the merkle tree before the first update
        uint128 preRootTimestamp = uint128(block.timestamp);

        messengerAddress = Predeploys.L2_CROSS_DOMAIN_MESSENGER;

        /// @notice Initialize the OpWorldID contract
        id = new OpWorldID();

        id.initialize(preRoot, preRootTimestamp);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "OPWorldID");
    }

    function test_onlyOwner_notMessenger_reverts() external {
        vm.expectRevert("CrossDomainOwnable2: caller is not the messenger");
        setter.set(1);
    }

    /// @notice Test that you can insert new root and check if it is valid
    function test_receiveVerifyRoot_succeeds() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);
        vm.prank(messengerAddress);
        id.receiveRoot(newRoot, newRootTimestamp);
        assertTrue(id.checkValidRoot(newRoot));
    }

    /// @notice Test that you can insert an invalid root and check that it is invalid
    function test_receiveVerifyInvalidRoot_reverts() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);
        uint256 randomRoot = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;
        vm.prank(messengerAddress);
        id.receiveRoot(newRoot, newRootTimestamp);
        vm.expectRevert(OpWorldID.NonExistentRoot.selector);
        id.checkValidRoot(randomRoot);
    }

    /// @notice Test that you can insert a root and check it has expired if more than 7 days have passed
    function test_expiredRoot_reverts() public {
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.prank(messengerAddress);
        id.receiveRoot(newRoot, newRootTimestamp);
        vm.warp(block.timestamp + 8 days);
        vm.expectRevert(OpWorldID.ExpiredRoot.selector);
        id.checkValidRoot(newRoot);
    }
}
