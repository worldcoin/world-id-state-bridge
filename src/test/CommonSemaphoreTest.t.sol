pragma solidity ^0.8.15;

import {SemaphoreVerifier} from "./SemaphoreVerifier16.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title Common Semaphore Verifier Test Contract
/// @author Worldcoin
/// @notice A contract that generates the shared test cases for the SemaphoreVerifier contract.
contract CommonSemaphoreVerifierTest is PRBTest {
    ///////////////////////////////////////////////////////////////////////////////
    ///                              CONTRACT DATA                              ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice The SemaphoreVerifier contract to test.
    SemaphoreVerifier internal verifier;

    /// The proof is invalid.
    /// @dev This can mean that provided Groth16 proof points are not on their
    /// curves, that pairing equation fails, or that the proof is not for the
    /// provided public input.
    error ProofInvalid();

    ///////////////////////////////////////////////////////////////////
    ///                          INCLUSION                          ///
    ///////////////////////////////////////////////////////////////////
    /// @dev generated using https://github.com/worldcoin/semaphore-mock
    /// steps:
    /// 1. cargo run --release generate-identities --identities 10
    /// 2. cargo run --release prove-inclusion --identities out/random_identities.json --tree-depth 16 --identity-index 3
    /// @dev params from `src/test/data/InclusionProof.json` (output of step 2.)
    uint256 internal constant inclusionRoot =
        0xdf9f0cb5a3afe2129e349c1435bfbe9e6f091832fdfa7b739b61c5db2cbdde9;
    uint256 internal constant inclusionSignalHash =
        0xbc6bb462e38af7da48e0ae7b5cbae860141c04e5af2cf92328cd6548df111f;
    uint256 internal constant inclusionNullifierHash =
        0x2887375654a2f83868b277f3836678aa55475fd5c840b117913ea4a7c9ded6fc;
    uint256 internal constant inclusionExternalNullifierHash =
        0xfd3a1e9736c12a5d4a31f26362b577ccafbd523d358daf40cdc04d90e17f77;

    uint256[8] inclusionProof;

    constructor() {
        verifier = new SemaphoreVerifier();
        // Create the inclusion proof term.
        // output from semaphore-mtb prove in src/test/data/InclusionProof.json
        //
        /// @dev generated using https://github.com/worldcoin/semaphore-mock
        /// steps:
        /// 1. cargo run --release generate-identities --identities 10
        /// 2. cargo run --release prove-inclusion --identities out/random_identities.json --tree-depth 16 --identity-index 3
        inclusionProof = [
            0x27d70bdecb420a7322a0e44ef68345fc67e9903a3980762c23dfda5cf4d65715,
            0x1aba064ef272dd53b498d856c711890249a63a46825fe6d332fc5868ad854ef4,
            0x23a76f9777710f268d2092d859344cdc8d7f77abef35695f89d1ebf771d8a520,
            0x295ab87eb7c0ad9470ec2b56b35309f5e4576679ef6180ed78124e3f549f125d,
            0x1da63a007225659d3a70a2dfe807df5c3e8423bfd8e059d72909a1def161573f,
            0x2578db76ee9f64ff4eb0b532cb796dfa27d86ae8cd29e2d6b32f9428c71acb8b,
            0xd00d49d5db4c5b11a13aca379f5c3c627a6e8fc1c4470e7a56017307aca51a2,
            0xf6ee8db704ecb5c149e5a046a03e8767ba5a818c08320f6245070e4c0e99b77
        ];
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               TEST CASES                                ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Tests that Semaphore proofs verify correctly.
    function testValidProof() public {
        verifier.verifyProof(
            inclusionProof,
            [
                inclusionRoot,
                inclusionNullifierHash,
                inclusionSignalHash,
                inclusionExternalNullifierHash
            ]
        );
    }

    /// @notice Tests that invalid Semaphore proofs revert
    ///
    /// @param proof The proof to test.
    /// @param input The public input to test.
    function testInvalidProof(uint256[8] calldata proof, uint256[4] calldata input) public {
        bool success;
        bytes memory returnData;

        vm.expectRevert(ProofInvalid.selector);
        (success, returnData) = address(verifier).staticcall(
            abi.encodeWithSelector(verifier.verifyProof.selector, proof, input)
        );
    }
}
