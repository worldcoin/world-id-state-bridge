// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

/// @dev Demo deployments
/// @custom:deployment Goerli 0x1ca56798e14fc4cb75de85cc1d465231eaf242e3
/// @custom:link https://goerli.etherscan.io/address/0x1ca56798e14fc4cb75de85cc1d465231eaf242e3
import {Script} from "forge-std/Script.sol";
import {StateBridge} from "src/StateBridge.sol";

/// @title State Bridge deployment script
/// @notice forge script to deploy StateBridge.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make local-mock`, `make deploy` or `make deploy-testnet`.
contract DeployStateBridge is Script {
    StateBridge public bridge;

    address public skaleWorldIDAddress;
    address public skale_IMAAddress_mainnet;

    // address public opWorldIDAddress;
    // address public polygonWorldIDAddress;
    address public worldIDIdentityManagerAddress;
    // address public crossDomainMessengerAddress;
    address public stateBridgeAddress;

    // address public checkpointManagerAddress;
    // address public fxRootAddress;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/src/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function setUp() public {
        skale_IMAAddress_mainnet = address(0x08913E0DC2BA60A1626655581f701bCa84f42324);

        ///////////////////////////////////////////////////////////////////
        ///                           POLYGON                           ///
        ///////////////////////////////////////////////////////////////////

        // https://static.matic.network/network/testnet/mumbai/index.json
        // RoootChainManagerProxy
        //checkpointManagerAddress = address(0x2890bA17EfE978480615e330ecB65333b880928e);

        // FxRoot
        // fxRootAddress = address(0x3d1d3E34f7fB6D26245E6640E1c50710eFFf15bA);

        ///////////////////////////////////////////////////////////////////
        ///                           OPTIMISM                          ///
        ///////////////////////////////////////////////////////////////////
        //crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);

        ///////////////////////////////////////////////////////////////////
        ///                           WORLD ID                          ///
        ///////////////////////////////////////////////////////////////////
        worldIDIdentityManagerAddress =
            abi.decode(vm.parseJson(json, ".worldIDIdentityManagerAddress"), (address));
        //opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        //polygonWorldIDAddress = abi.decode(vm.parseJson(json, ".polygonWorldIDAddress"), (address));
        skaleWorldIDAddress = abi.decode(vm.parseJson(json, ".skaleWorldIDAddress"), (address));
    }

    function run() public {
        vm.startBroadcast(privateKey);

        bridge = new StateBridge(
            worldIDIdentityManagerAddress,
            skaleWorldIDAddress,
            skale_IMAAddress_mainnet
        );

        //   bridge.setFxChildTunnel(polygonWorldIDAddress);

        vm.stopBroadcast();
    }
}
