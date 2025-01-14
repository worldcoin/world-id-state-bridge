// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @dev Demo deployments
import {Script} from "forge-std/Script.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";

/// @title Optimism State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol on Optimism
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployOpStateBridgeSepolia is Script {
    OpStateBridge public bridge;

    address public opWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    address public opCrossDomainMessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                           OPTIMISM                          ///
        ///////////////////////////////////////////////////////////////////
        opCrossDomainMessengerAddress = address(0x58Cc85b8D04EA49cC6DBd3CbFFd00B4B8D6cb3ef);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        opWorldIDAddress = vm.envAddress("OPTIMISM_WORLD_ID_ADDRESS");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new OpStateBridge(
            worldIDIdentityManagerAddress, opWorldIDAddress, opCrossDomainMessengerAddress
        );

        vm.stopBroadcast();
    }
}
