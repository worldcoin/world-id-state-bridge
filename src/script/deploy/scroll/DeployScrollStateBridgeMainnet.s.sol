// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/// @dev Demo deployments
import {Script} from "forge-std/Script.sol";
import {ScrollStateBridge} from "src/ScrollStateBridge.sol";

/// @title Scroll State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol on Scroll
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployScrollStateBridgeMainnet is Script {
    ScrollStateBridge public bridge;
    address public scrollL1MessengerAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    uint256 public privateKey = vm.envUint("PRIVATE_KEY");

    address public worldIDIdentityManagerAddress;
    address public scrollWorldIDAddress;

    function setUp() public {
        ///////////////////////////////////////////////////////////////////
        ///                            SCROLL                           ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress = vm.envAddress("WORLD_IDENTITY_MANAGER_ADDRESS");
        scrollWorldIDAddress = vm.envAddress("SCROLL_WORLD_ID_ADDRESS");
        // Mainnet
        // https://docs.scroll.io/en/developers/scroll-contracts/
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
