// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";
import {ICrossDomainMessenger} from "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {ICrossDomainOwnable3} from "../../src/interfaces/ICrossDomainOwnable3.sol";

/// @notice Initializes the StateBridge contract
contract TransferOwnershipOfOpWorldID is Script {
    address public immutable stateBridgeAddress;
    address public immutable opWorldIDAdress;
    address public immutable crossDomainMessengerAddress;

    OpWorldID public opWorldID;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    constructor() {
        /*//////////////////////////////////////////////////////////////
                                 GOERLI
        //////////////////////////////////////////////////////////////*/
        opWorldIDAdress = address(0x09A02586dAf43Ca837b45F34dC2661d642b8Da15);
        stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
        /*//////////////////////////////////////////////////////////////
                                MAINNET (TBD)
        //////////////////////////////////////////////////////////////*/
        // opWorldIDAdress = address(0x09A02586dAf43Ca837b45F34dC2661d642b8Da15);
        // stateBridgeAddress = address(0x8438ba278cF0bf6dc75a844755C7A805BB45984F);             }
        // crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
    }

    function run() public {
        uint256 opWorldIDKey = vm.envUint("OP_WORLDID_PRIVATE_KEY");

        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(opWorldIDKey);

        crossDomainTransferOwnership(stateBridgeAddress, isLocal);

        vm.stopBroadcast();
    }

    function crossDomainTransferOwnership(address newOwner, bool _isLocal) internal {
        bytes memory message;

        message = abi.encodeCall(ICrossDomainOwnable3.transferOwnership, (newOwner, _isLocal));

        // ICrossDomainMessenger is an interface for the L1 Messenger contract deployed on Goerli address
        ICrossDomainMessenger(crossDomainMessengerAddress).sendMessage(
            // Contract address on Optimism
            opWorldIDAdress,
            message,
            1000000 // within the free gas limit
        );
    }
}
