pragma solidity ^0.8.15;

import {BytesUtils} from "src/utils/BytesUtils.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title BytesUtils Test
/// @author Worldcoin
/// @notice Tests the low-level assembly functions `grabSelector` and `stripSelector` in the BytesUtils library
contract BytesUtilsTest is PRBTest, StdCheats {
    /// @notice Emitted when the payload is too short to contain a selector (at least 4 bytes).
    error PayloadTooShort();

    ///////////////////////////////////////////////////////////////////
    ///                           SUCCEEDS                          ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Tests that the `grabSelector` function returns the first 4 bytes of a payload.
    function testGrabSelectorSucceeds(string memory sig) public {
        bytes4 selector = bytes4(keccak256(abi.encodePacked(sig)));

        bytes memory encodedMessage = abi.encodeWithSignature(sig, 4844, 4337);

        bytes4 grabbedSelector = BytesUtils.grabSelector(encodedMessage);

        assertEq(selector, grabbedSelector);
    }

    /// @notice Tests that the `stripSelector` function returns the payload after the first 4 bytes.
    function testStripSelectorSucceeds(string memory sig) public {
        bytes memory encodedMessage = abi.encodeWithSignature(sig, 4844, 4337);

        bytes memory strippedPayload = BytesUtils.stripSelector(encodedMessage);

        bytes memory expectedPayload = abi.encodePacked(uint256(4844), uint256(4337));

        assertEq(strippedPayload, expectedPayload);
    }

    /// @notice tests that different function signatures create different selectors (a bit obvious)
    function testDifferentSigsDontCollideSucceeds(string memory sig, string memory notSig) public {
        vm.assume(keccak256(bytes(sig)) != keccak256(bytes(notSig)));

        bytes4 selector = bytes4(keccak256(abi.encodePacked(sig)));

        bytes memory encodedMessage = abi.encodeWithSignature(notSig, 4844, 4337);

        bytes4 grabbedSelector = BytesUtils.grabSelector(encodedMessage);

        assertTrue(selector != grabbedSelector);
    }

    ///////////////////////////////////////////////////////////////////
    ///                           REVERTS                           ///
    ///////////////////////////////////////////////////////////////////

    /// @notice Tests that the `grabSelector` function reverts when the payload is too short (<4 bytes)
    /// to contain a selector.
    function testGrabSelectorPayloadTooShortReverts(
        bytes2 lessThanFourBytes,
        bytes4 fourOrMoreBytes
    ) public {
        // works fine
        BytesUtils.grabSelector(abi.encodePacked(fourOrMoreBytes));

        vm.expectRevert(PayloadTooShort.selector);

        // reverts
        BytesUtils.grabSelector(abi.encodePacked(lessThanFourBytes));
    }

    /// @notice Tests that the `stripSelector` function reverts when the payload is too short (<5 bytes)
    /// to contain a payload after the selctor
    function testStripSelectorPayloadTooShortReverts(
        bytes4 fourBytesOrLess,
        bytes5 moreThanFourBytes
    ) public {
        // works fine
        BytesUtils.stripSelector(abi.encodePacked(moreThanFourBytes));

        vm.expectRevert(PayloadTooShort.selector);

        // reverts
        BytesUtils.stripSelector((abi.encodePacked(fourBytesOrLess)));
    }
}
