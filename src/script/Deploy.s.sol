// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script, console2} from "forge-std/Script.sol";

import {OpWorldID} from "src/OpWorldID.sol";
import {OpStateBridge} from "src/OpStateBridge.sol";
import {PolygonWorldID} from "src/PolygonWorldID.sol";
import {PolygonStateBridge} from "src/PolygonStateBridge.sol";
import {MockWorldIDIdentityManager} from "src/mock/MockWorldIDIdentityManager.sol";
import {MockBridgedWorldID} from "src/mock/MockBridgedWorldID.sol";
import {MockStateBridge} from "src/mock/MockStateBridge.sol";
import {ICrossDomainOwnable3} from "src/interfaces/ICrossDomainOwnable3.sol";
import {IOpStateBridgeTransferOwnership} from "src/interfaces/IOpStateBridgeTransferOwnership.sol";

/// @title Deploy
/// @author Worldcoin
/// @notice Unified deployment script for World ID State Bridge contracts.
/// @dev Usage:
///   DEPLOY_TARGET=op-world-id forge script script/Deploy.s.sol --broadcast --rpc-url $RPC_URL
///
/// Available targets:
///   deploy-op-stack          - Deploy OpWorldID (L2) + OpStateBridge (L1) + transfer ownership
///   op-world-id              - Deploy OpWorldID to an OP Stack L2
///   op-state-bridge          - Deploy OpStateBridge on Ethereum L1
///   polygon-world-id         - Deploy PolygonWorldID on Polygon
///   polygon-state-bridge     - Deploy PolygonStateBridge on Ethereum L1
///   mock                     - Deploy mock contracts for testing
///   initialize-polygon       - Set fxRootTunnel on PolygonWorldID
///   transfer-ownership-op    - Transfer OpWorldID ownership (local or cross-domain)
///   set-gas-limits           - Configure gas limits on OpStateBridge
contract Deploy is Script {
    uint8 constant TREE_DEPTH = 30;

    function run() public {
        string memory target = vm.envString("DEPLOY_TARGET");
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        bytes32 t = keccak256(bytes(target));

        // Multi-fork targets manage their own broadcast
        if (t == keccak256("deploy-op-stack")) {
            _deployOpStack(deployerKey);
            return;
        }

        vm.startBroadcast(deployerKey);

        if (t == keccak256("deploy-op-stack")) {
            _deployOpStack(deployerKey);
        } else if (t == keccak256("polygon-world-id")) {
            _deployPolygonWorldID();
        } else if (t == keccak256("polygon-state-bridge")) {
            _deployPolygonStateBridge();
        } else if (t == keccak256("mock")) {
            _deployMock();
        } else if (t == keccak256("initialize-polygon")) {
            _initializePolygon();
        } else if (t == keccak256("transfer-ownership-op")) {
            _transferOwnershipOp();
        } else if (t == keccak256("set-gas-limits")) {
            _setGasLimits();
        } else {
            revert(string.concat("Unknown DEPLOY_TARGET: ", target));
        }

        vm.stopBroadcast();
    }

    /// @notice Deploy OpWorldID to an OP Stack L2 chain
    function _deployOpWorldID() internal {
        OpWorldID id = new OpWorldID(TREE_DEPTH);
        console2.log("OpWorldID deployed at:", address(id));
    }

    /// @notice Deploy OpWorldID on L2, OpStateBridge on L1, and transfer OpWorldID ownership
    ///         to the state bridge (cross-domain).
    /// @dev Requires env: ETHEREUM_RPC, L2_RPC, WORLD_ID_IDENTITY_MANAGER, CROSS_DOMAIN_MESSENGER
    ///      Uses multi-fork broadcasting — do NOT pass --rpc-url, the RPCs come from env vars.
    ///      Usage: DEPLOY_TARGET=deploy-op-stack forge script script/Deploy.s.sol --broadcast
    function _deployOpStack(uint256 deployerKey) internal {
        string memory l1Rpc = vm.envString("ETHEREUM_RPC");
        string memory l2Rpc = vm.envString("L2_RPC");
        address worldID = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");
        address messenger = vm.envAddress("CROSS_DOMAIN_MESSENGER");

        uint256 l2Fork = vm.createFork(l2Rpc);
        uint256 l1Fork = vm.createFork(l1Rpc);

        // Step 1: Deploy OpWorldID on L2
        vm.selectFork(l2Fork);
        vm.startBroadcast(deployerKey);
        OpWorldID opWorldID = new OpWorldID(TREE_DEPTH);
        console2.log("OpWorldID deployed at:", address(opWorldID));
        vm.stopBroadcast();

        // Step 2: Deploy OpStateBridge on L1
        vm.selectFork(l1Fork);
        vm.startBroadcast(deployerKey);
        OpStateBridge bridge = new OpStateBridge(worldID, address(opWorldID), messenger);
        bytes memory call = abi.encodeCall(
            IOpStateBridgeTransferOwnership.transferOwnershipOp, (address(bridge), false)
        );

        (bool ok,) = address(bridge).call(call);
        require(ok, "call failed");
        console2.log("OpStateBridge deployed at:", address(bridge));
        vm.stopBroadcast();
    }

    /// @notice Deploy PolygonWorldID on Polygon
    /// @dev Requires: FX_CHILD
    function _deployPolygonWorldID() internal {
        address fxChild = vm.envAddress("FX_CHILD");

        PolygonWorldID id = new PolygonWorldID(TREE_DEPTH, fxChild);
        console2.log("PolygonWorldID deployed at:", address(id));
    }

    /// @notice Deploy PolygonStateBridge on Ethereum L1
    /// @dev Requires: CHECKPOINT_MANAGER, FX_ROOT, WORLD_ID_IDENTITY_MANAGER
    ///      Optional: POLYGON_WORLD_ID_ADDRESS (to set fxChildTunnel in same tx)
    function _deployPolygonStateBridge() internal {
        address checkpointManager = vm.envAddress("CHECKPOINT_MANAGER");
        address fxRoot = vm.envAddress("FX_ROOT");
        address worldID = vm.envAddress("WORLD_ID_IDENTITY_MANAGER");

        PolygonStateBridge bridge = new PolygonStateBridge(checkpointManager, fxRoot, worldID);
        console2.log("PolygonStateBridge deployed at:", address(bridge));

        // Optionally set fxChildTunnel if address is provided
        address polygonWorldID = vm.envOr("POLYGON_WORLD_ID_ADDRESS", address(0));
        if (polygonWorldID != address(0)) {
            bridge.setFxChildTunnel(polygonWorldID);
            console2.log("fxChildTunnel set to:", polygonWorldID);
        }
    }

    /// @notice Deploy mock contracts for local testing
    /// @dev Optional: SAMPLE_ROOT (defaults to 0x111)
    function _deployMock() internal {
        uint256 sampleRoot = vm.envOr("SAMPLE_ROOT", uint256(0x111));

        MockWorldIDIdentityManager mockWorldID = new MockWorldIDIdentityManager(sampleRoot);
        console2.log("MockWorldIDIdentityManager deployed at:", address(mockWorldID));

        MockBridgedWorldID mockBridgedWorldID = new MockBridgedWorldID(TREE_DEPTH);
        console2.log("MockBridgedWorldID deployed at:", address(mockBridgedWorldID));

        MockStateBridge mockBridge =
            new MockStateBridge(address(mockWorldID), address(mockBridgedWorldID));
        console2.log("MockStateBridge deployed at:", address(mockBridge));

        mockBridge.propagateRoot();
        console2.log("Mock root propagated");
    }

    /// @notice Initialize PolygonWorldID by setting fxRootTunnel
    /// @dev Requires: POLYGON_WORLD_ID_ADDRESS, POLYGON_STATE_BRIDGE_ADDRESS
    function _initializePolygon() internal {
        address polygonWorldID = vm.envAddress("POLYGON_WORLD_ID_ADDRESS");
        address stateBridge = vm.envAddress("POLYGON_STATE_BRIDGE_ADDRESS");

        PolygonWorldID(polygonWorldID).setFxRootTunnel(stateBridge);
        console2.log("fxRootTunnel set to:", stateBridge);
    }

    /// @notice Transfer ownership of OpWorldID
    /// @dev Requires: OP_WORLD_ID_ADDRESS, NEW_OWNER
    ///      Optional: IS_LOCAL (defaults to false for cross-domain transfer)
    ///      For local transfer: run on the OP Stack chain
    ///      For cross-domain transfer via state bridge: OP_STATE_BRIDGE_ADDRESS
    function _transferOwnershipOp() internal {
        address worldId = vm.envAddress("OP_WORLD_ID_ADDRESS");
        address stateBridgeAddress = vm.envAddress("OP_STATE_BRIDGE_ADDRESS");
        ICrossDomainOwnable3(worldId).transferOwnership(stateBridgeAddress, false);
        console2.log("Ownership transfer initiated. New owner:", stateBridgeAddress);
    }

    /// @notice Configure gas limits on an OpStateBridge
    /// @dev Requires: OP_STATE_BRIDGE_ADDRESS
    ///      Optional: GAS_LIMIT_PROPAGATE_ROOT, GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY,
    ///                GAS_LIMIT_TRANSFER_OWNERSHIP (all default to 100000)
    function _setGasLimits() internal {
        address bridge = vm.envAddress("OP_STATE_BRIDGE_ADDRESS");
        uint32 defaultGas = 100000;

        uint32 gasLimitPropagateRoot =
            uint32(vm.envOr("GAS_LIMIT_PROPAGATE_ROOT", uint256(defaultGas)));
        uint32 gasLimitSetExpiry =
            uint32(vm.envOr("GAS_LIMIT_SET_ROOT_HISTORY_EXPIRY", uint256(defaultGas)));
        uint32 gasLimitTransferOwnership =
            uint32(vm.envOr("GAS_LIMIT_TRANSFER_OWNERSHIP", uint256(defaultGas)));

        OpStateBridge opBridge = OpStateBridge(bridge);
        opBridge.setGasLimitPropagateRoot(gasLimitPropagateRoot);
        opBridge.setGasLimitSetRootHistoryExpiry(gasLimitSetExpiry);
        opBridge.setGasLimitTransferOwnershipOp(gasLimitTransferOwnership);

        console2.log("Gas limits set on bridge:", bridge);
    }
}
