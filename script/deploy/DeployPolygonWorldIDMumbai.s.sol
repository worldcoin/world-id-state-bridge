// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @dev Demo deployments
/// @custom:deployment Polygon Mumbai 0x771ef55049f02f08101f68c6e71653ab920a98e9
/// @custom:link https://mumbai.polygonscan.com/address/0x771ef55049f02f08101f68c6e71653ab920a98e9#code
import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "../../src/PolygonWorldID.sol";

/// @title PolygonWorldID deployment script on Polygon Mumbai
/// @notice forge script to deploy PolygonWorldID.sol
/// @author Worldcoin
/// @dev Can be executed by running `make mock`, `make deploy` or `make deploy-testnet`.
contract DeployPolygonWorldIDMumbai is Script {
    address public stateBridgeAddress;

    // Polygon PoS Mumbai Testnet Child Tunnel
    address public fxChildAddress = address(0xCf73231F28B7331BBe3124B907840A94851f9f11);

    PolygonWorldID public polygonWorldId;
    uint256 public privateKey;

    uint8 public treeDepth;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    function setUp() public {
        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        treeDepth = abi.decode(vm.parseJson(json, ".treeDepth"), (uint8));
    }

    function run() external {
        vm.startBroadcast(privateKey);

        polygonWorldId = new PolygonWorldID(treeDepth, fxChildAddress);

        vm.stopBroadcast();
    }
}
