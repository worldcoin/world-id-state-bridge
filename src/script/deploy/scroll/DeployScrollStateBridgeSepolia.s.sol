// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @dev Demo deployments
import {Script} from "forge-std/Script.sol";
import {ScrollStateBridge} from "src/ScrollStateBridge.sol";

/// @title Scroll State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol on Scroll
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployScrollStateBridgeSepolia is Script {
    ScrollStateBridge public bridge;
    address public scrollL1MessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    address public worldIDIdentityManagerAddress;
    address public scrollWorldIDAddress;

    function setUp() public {
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        scrollWorldIDAddress = vm.envAddress("SCROLL_WORLD_ID_ADDRESS");
        ///////////////////////////////////////////////////////////////////
        ///                            SCROLL                           ///
        ///////////////////////////////////////////////////////////////////
        // Sepolia
        // https://docs.scroll.io/en/developers/scroll-contracts/#scroll-sepolia-testnet
        scrollL1MessengerAddress = address(0x50c7d3e7f7c656493D1D76aaa1a836CedfCBB16A);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new ScrollStateBridge(
            worldIDIdentityManagerAddress, scrollWorldIDAddress, scrollL1MessengerAddress
        );

        vm.stopBroadcast();
    }
}
