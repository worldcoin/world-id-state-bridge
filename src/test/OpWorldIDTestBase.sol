// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Predeploys} from "src/vendor/optimism/Predeploys.sol";
import {Hashing} from "src/vendor/optimism/Hashing.sol";

/// @title MockL2CrossDomainMessenger
/// @notice Minimal mock of the OP Stack L2CrossDomainMessenger for testing.
/// @dev Storage is padded so that `_xDomainMsgSender` lives at slot 204,
///      matching the real L2CrossDomainMessenger storage layout for vm.store compatibility.
contract MockL2CrossDomainMessenger {
    /// @dev Occupies slots 0-203 to align _xDomainMsgSender at slot 204.
    uint256[204] private __gap;

    /// @dev Slot 204: mirrors CrossDomainMessenger._xDomainMsgSender.
    address internal _xDomainMsgSender;

    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);

    function xDomainMessageSender() external view returns (address) {
        return _xDomainMsgSender;
    }

    /// @notice Simulates relayMessage as the L2CrossDomainMessenger would.
    function relayMessage(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _minGasLimit,
        bytes calldata _message
    ) external payable {
        bytes32 versionedHash = Hashing.hashCrossDomainMessageV1(
            _nonce, _sender, _target, _value, _minGasLimit, _message
        );

        _xDomainMsgSender = _sender;
        (bool success,) = _target.call{value: _value}(_message);
        _xDomainMsgSender = address(0);

        if (success) {
            emit RelayedMessage(versionedHash);
        } else {
            emit FailedRelayedMessage(versionedHash);
        }
    }
}

/// @title OpWorldIDTestBase
/// @notice Base test providing OP Stack infrastructure for OpWorldID tests.
/// @dev Replaces the CommonTest / Bridge_Initializer from the deleted lib/contracts.
abstract contract OpWorldIDTestBase is Test {
    address alice = address(128);
    address bob = address(256);
    address L1Messenger = address(0xdEaD);
    MockL2CrossDomainMessenger L2Messenger;

    event FailedRelayedMessage(bytes32 indexed msgHash);

    function setUp() public virtual {
        MockL2CrossDomainMessenger impl = new MockL2CrossDomainMessenger();
        vm.etch(Predeploys.L2_CROSS_DOMAIN_MESSENGER, address(impl).code);
        L2Messenger = MockL2CrossDomainMessenger(Predeploys.L2_CROSS_DOMAIN_MESSENGER);
    }
}
