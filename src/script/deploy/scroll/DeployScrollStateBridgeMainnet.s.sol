// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/// @dev Demo deployments
import {Script} from "forge-std/Script.sol";
import {ScrollStateBridge} from "src/ScrollStateBridge.sol";

/// @title Scroll State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol on Scroll
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployScrollStateBridgeGoerli is Script {
    ScrollStateBridge public bridge;
    address public scrollL1MessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    address public worldIDIdentityManagerAddress = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");
    address public scrollWorldIDAddress = vm.envAddress("SCROLL_WORLD_ID");

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            SCROLL                           ///
        ///////////////////////////////////////////////////////////////////
        // Mainnet
        scrollL1MessengerAddress = address(0x6774Bcbd5ceCeF1336b5300fb5186a12DDD8b367);
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new ScrollStateBridge(
            worldIDIdentityManagerAddress, scrollWorldIDAddress, scrollL1MessengerAddress
        );

        vm.stopBroadcast();
    }
}
