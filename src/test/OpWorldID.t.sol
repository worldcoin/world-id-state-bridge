// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @dev using Test from forge-std which is inherited from Optimism's CommonTest.t.sol
// import { PRBTest } from "@prb/test/PRBTest.sol";
// import { StdCheats } from "forge-std/StdCheats.sol";
import { OpWorldID } from "src/OpWorldID.sol";
import { WorldIDBridge } from "src/abstract/WorldIDBridge.sol";
import { SemaphoreTreeDepthValidator } from "src/utils/SemaphoreTreeDepthValidator.sol";
import { L2CrossDomainMessenger } from "@eth-optimism/contracts-bedrock/contracts/L2/L2CrossDomainMessenger.sol";
import { Predeploys } from "@eth-optimism/contracts-bedrock/contracts/libraries/Predeploys.sol";
import { CommonTest, Messenger_Initializer } from "@eth-optimism/contracts-bedrock/contracts/test/CommonTest.t.sol";
import { AddressAliasHelper } from "@eth-optimism/contracts-bedrock/contracts/vendor/AddressAliasHelper.sol";
import { Encoding } from "@eth-optimism/contracts-bedrock/contracts/libraries/Encoding.sol";
import { Bytes32AddressLib } from "solmate/src/utils/Bytes32AddressLib.sol";

/// @title OpWorldIDTest
/// @author Worldcoin
/// @notice A test contract for OpWorldID
/// @dev The OpWorldID contract is deployed on Optimism and is called by the StateBridge contract.
/// @dev This contract uses the Optimism CommonTest.t.sol testing tool suite.
contract OpWorldIDTest is Messenger_Initializer {
    /*//////////////////////////////////////////////////////////////
                                WORLD ID
    //////////////////////////////////////////////////////////////*/
    /// @notice The OpWorldID contract
    OpWorldID internal id;

    /// @notice MarkleTree depth
    uint8 internal treeDepth = 16;

    /// @notice OpenZeppelin Ownable.sol transferOwnership event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice CrossDomainOwnable3.sol transferOwnership event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner, bool isLocal);

    function testConstructorWithInvalidTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(!SemaphoreTreeDepthValidator.validate(actualTreeDepth));
        vm.expectRevert(abi.encodeWithSignature("UnsupportedTreeDepth(uint8)", actualTreeDepth));

        new OpWorldID(actualTreeDepth);
    }

    function setUp() public override {
        /// @notice CrossDomainOwnable3 setup
        super.setUp();

        /// @notice Initialize the OpWorldID contract
        vm.prank(alice);
        id = new OpWorldID(treeDepth);

        /// @dev label important addresses
        vm.label(address(this), "Sender");
        vm.label(address(id), "OPWorldID");
    }

    function _switchToCrossDomainOwnership(OpWorldID _id) internal {
        vm.expectEmit(true, true, true, true);

        // OpenZeppelin Ownable.sol transferOwnership event
        emit OwnershipTransferred(alice, alice);

        // CrossDomainOwnable3.sol transferOwnership event
        emit OwnershipTransferred(alice, alice, false);

        // CrossDomainOwnable3.sol transferOwnership to crossDomain address (as alice and to alice)
        vm.prank(_id.owner());
        id.transferOwnership({ _owner: alice, _isLocal: false });
    }

    /// @notice Test that when _isLocal = false, a contract that is not the L2 Messenger can't call the contract
    /// @param newRoot The root of the merkle tree after the first update
    function test_onlyOwner_notMessenger_reverts(uint256 newRoot) external {
        _switchToCrossDomainOwnership(id);

        uint128 newRootTimestamp = uint128(block.timestamp + 100);

        // calling locally (not as the messenger)
        vm.prank(bob);
        vm.expectRevert("CrossDomainOwnable3: caller is not the messenger");
        id.receiveRoot(newRoot, newRootTimestamp);
    }

    /// @notice Test that a non-owner can't insert a new root
    /// @param newRoot The root of the merkle tree after the first update
    function test_onlyOwner_notOwner_reverts(uint256 newRoot) external {
        _switchToCrossDomainOwnership(id);

        // set the xDomainMsgSender storage slot as bob
        bytes32 key = bytes32(uint256(204));
        bytes32 value = Bytes32AddressLib.fillLast12Bytes(address(bob));
        vm.store(address(L2Messenger), key, value);

        uint128 newRootTimestamp = uint128(block.timestamp + 100);

        vm.prank(address(L2Messenger));
        vm.expectRevert("CrossDomainOwnable3: caller is not the owner");
        id.receiveRoot(newRoot, newRootTimestamp);
    }

    /// @notice Test that you can insert new root and check if it is valid
    /// @param newRoot The root of the merkle tree after the first update
    function test_receiveVerifyRoot_succeeds(uint256 newRoot) public {
        _switchToCrossDomainOwnership(id);

        address owner = id.owner();
        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);

        // set the xDomainMsgSender storage slot to the L1Messenger
        vm.prank(AddressAliasHelper.applyL1ToL2Alias(address(L1Messenger)));
        L2Messenger.relayMessage(
            Encoding.encodeVersionedNonce(0, 1),
            owner,
            address(id),
            0,
            0,
            abi.encodeWithSelector(id.receiveRoot.selector, newRoot, newRootTimestamp)
        );

        assertTrue(id.checkValidRoot(newRoot));
    }

    /// @notice Test that a root that hasn't been inserted is invalid
    /// @param newRoot The root of the merkle tree after the first update
    function test_receiveVerifyInvalidRoot_reverts(uint256 newRoot) public {
        _switchToCrossDomainOwnership(id);

        address owner = id.owner();

        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        vm.warp(block.timestamp + 200);
        uint256 randomRoot = 0x712cab3414951eba341ca234aef42142567c6eea50371dd528d57eb2b856d238;

        // set the xDomainMsgSender storage slot to the L1Messenger
        vm.prank(AddressAliasHelper.applyL1ToL2Alias(address(L1Messenger)));
        L2Messenger.relayMessage(
            Encoding.encodeVersionedNonce(0, 1),
            owner,
            address(id),
            0,
            0,
            abi.encodeWithSelector(id.receiveRoot.selector, newRoot, newRootTimestamp)
        );

        vm.expectRevert(WorldIDBridge.NonExistentRoot.selector);
        id.checkValidRoot(randomRoot);
    }

    /// @notice Test that you can insert a root and check it has expired if more than 7 days have passed
    /// @param newRoot The root of the merkle tree after the first update (forge fuzzing)
    /// @param secondRoot The root of the merkle tree after the second update (forge fuzzing)
    function test_expiredRoot_reverts(uint256 newRoot, uint256 secondRoot) public {
        vm.assume(newRoot != secondRoot && newRoot != 0 && secondRoot != 0);

        _switchToCrossDomainOwnership(id);

        address owner = id.owner();

        uint128 newRootTimestamp = uint128(block.timestamp + 100);
        uint128 secondRootTimestamp = uint128(newRootTimestamp + 1);

        // set the xDomainMsgSender storage slot to the L1Messenger
        vm.prank(AddressAliasHelper.applyL1ToL2Alias(address(L1Messenger)));
        L2Messenger.relayMessage(
            Encoding.encodeVersionedNonce(0, 1),
            owner,
            address(id),
            0,
            0,
            abi.encodeWithSelector(id.receiveRoot.selector, newRoot, newRootTimestamp)
        );

        vm.roll(block.number + 100);
        vm.warp(block.timestamp + 200);
        vm.prank(AddressAliasHelper.applyL1ToL2Alias(address(L1Messenger)));
        L2Messenger.relayMessage(
            Encoding.encodeVersionedNonce(1, 1),
            owner,
            address(id),
            0,
            0,
            abi.encodeWithSelector(id.receiveRoot.selector, secondRoot, secondRootTimestamp)
        );

        vm.expectRevert(WorldIDBridge.ExpiredRoot.selector);
        vm.warp(block.timestamp + 8 days);
        id.checkValidRoot(newRoot);
    }

    /// @notice Checks that it is possible to get the tree depth the contract was initialized with.
    function testCanGetTreeDepth(uint8 actualTreeDepth) public {
        // Setup
        vm.assume(SemaphoreTreeDepthValidator.validate(actualTreeDepth));

        id = new OpWorldID(actualTreeDepth);

        // Test
        assert(id.getTreeDepth() == actualTreeDepth);
    }
}
