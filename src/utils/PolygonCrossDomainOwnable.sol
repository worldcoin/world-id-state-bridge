// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title CrossDomainOwnable2
 * @notice This contract extends the OpenZeppelin `Ownable` contract for L2 contracts to be owned
 *         by contracts on L1. Note that this contract is meant to be used with systems that use
 *         the CrossDomainMessenger system. It will not work if the OptimismPortal is used
 *         directly.
 */
abstract contract PolygonCrossDomainOwnable is Ownable, Initializable {
    address _rootChainManagerProxy;

    constructor() {
        _disableInitializers();
    }

    /// @notice Sets the addresses for all the WorldID target chains
    /// @param rootChainManagerProxy Deployment address of the Polygon RootChainManagerProxy contract
    function initialize(address rootChainManagerProxy) public virtual reinitializer(1) {
        _rootChainManagerProxy = rootChainManagerProxy;
    }

    /**
     * @notice Overrides the implementation of the `onlyOwner` modifier to check that the unaliased
     *         `xDomainMessageSender` is the owner of the contract. This value is set to the caller
     *         of the L1CrossDomainMessenger.
     */
    function _checkOwner() internal view override {
        require(
            msg.sender == _rootChainManagerProxy,
            "PolygonCrossdomainOwnable: caller is not the root chain manager proxy contract"
        );
    }
}
