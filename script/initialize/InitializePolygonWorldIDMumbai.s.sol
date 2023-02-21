// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {PolygonWorldID} from "../../src/PolygonWorldID.sol";

/// @notice Initializes the StateBridge contract
contract InitializePolygonWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable polygonWorldIDAdress;

    uint256 public immutable preRoot;
    uint128 public immutable preRootTimestamp;

    PolygonWorldID public polygonWorldID;

    constructor() {
        polygonWorldIDAdress = address(0x09A02586dAf43Ca837b45F34dC2661d642b8Da15);
        stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        preRoot = 0x18f43331537ee2af2e3d758d50f72106467c6eea50371dd528d57eb2b856d238;
        preRootTimestamp = uint128(block.timestamp);
    }

    function run() public {
        uint256 polygonWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        vm.startBroadcast(polygonWorldIDKey);

        polygonWorldID = PolygonWorldID(polygonWorldIDAdress);

        polygonWorldID.initialize(preRoot, preRootTimestamp, stateBridgeAddress);

        vm.stopBroadcast();
    }
}
