// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IL2ScrollMessenger} from "@scroll-tech/contracts/L2/IL2ScrollMessenger.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title SrollCrossDomainOwnable
/// @author Worldcoin, OPLabsPBC
/// @notice This contract extends the OpenZeppelin `Ownable` contract for L2 contracts to be owned
///         by contracts on either L1 or L2. Note that this contract is meant to be used with
///         systems that use the ScrollMessenger system.
/// @dev Fork of CrossDomainOwnable3 from @eth-optimism/contracts-bedrock/contracts/L2/CrossDomainOwnable3
abstract contract ScrollCrossDomainOwnable is Ownable {
    /// @notice The L2ScrollMessenger is used to check whether a call is coming from L1.
    /// @dev Sepolia address on Scroll for the L2ScrollMessenger:
    /// https://docs.scroll.io/en/developers/scroll-contracts/
    address public immutable scrollMessengerAddress;
    IL2ScrollMessenger public messenger;

    /// @notice If true, the contract uses the standard Ownable _checkOwner function.
    ///         If false it false uses the cross domain _checkOwner function override.
    bool public isLocal = true;

    /// @notice Emits when ownership of the contract is transferred. Includes the
    ///         isLocal field in addition to the standard `Ownable` OwnershipTransferred event.
    /// @param previousOwner The previous owner of the contract.
    /// @param newOwner      The new owner of the contract.
    /// @param isLocal       Configures the `isLocal` contract variable.
    event OwnershipTransferred(
        address indexed previousOwner, address indexed newOwner, bool isLocal
    );

    /// @notice Initializes the scrollMessengerAddress
    constructor(address _messenger) {
        scrollMessengerAddress = _messenger;
        messenger = IL2ScrollMessenger(scrollMessengerAddress);
    }

    /// @notice Allows for ownership to be transferred with specifying the locality.
    /// @param _owner   The new owner of the contract.
    /// @param _isLocal Configures the locality of the ownership.
    function transferOwnership(address _owner, bool _isLocal) external onlyOwner {
        require(_owner != address(0), "ScrollCrossDomainOwnable: new owner is the zero address");

        address oldOwner = owner();
        _transferOwnership(_owner);
        isLocal = _isLocal;

        emit OwnershipTransferred(oldOwner, _owner, _isLocal);
    }

    /// @notice Overrides the implementation of the `onlyOwner` modifier to check that the unaliased
    ///         `xDomainMessageSender` is the owner of the contract. This value is set to the caller
    ///         of the L1ScrollMessenger.
    function _checkOwner() internal view override {
        if (isLocal) {
            require(owner() == msg.sender, "ScrollCrossDomainOwnable: caller is not the owner");
        } else {
            require(
                msg.sender == address(messenger),
                "ScrollCrossDomainOwnable: caller is not the messenger"
            );

            require(
                owner() == messenger.xDomainMessageSender(),
                "ScrollCrossDomainOwnable: caller is not the owner"
            );
        }
    }
}
