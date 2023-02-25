// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {WorldIDIdentityManagerImplV1} from "../../src/mock/WorldIDIdentityManagerImplV1.sol";

/// @notice Initializes the StateBridge contract
contract InitializeOpWorldID is Script {
    address public mockWorldIDAddress;

    uint256 public immutable postRoot;

    WorldIDIdentityManagerImplV1 public worldID;

    constructor() {
        mockWorldIDAddress = address(0x206d2C6A7A600BC6bD3A26A8A12DfFb64698C23C);
        postRoot = 0x5c1e52b41a571293b30efacd2afdb7173b20cfaf1f646c4ac9f96eb75848270;
    }

    function run() public {
        uint256 worldIDKey = vm.envUint("WORLDID_PRIVATE_KEY");

        vm.startBroadcast(worldIDKey);

        worldID = WorldIDIdentityManagerImplV1(mockWorldIDAddress);

        worldID.sendRootToStateBridge(postRoot);

        vm.stopBroadcast();
    }
}
