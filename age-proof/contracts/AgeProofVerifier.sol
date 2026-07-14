// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./verifier.sol";

contract AgeProofVerifier {
    IVerifier public immutable verifier;
    // The verification key has 10 inputs, but 8 are pairing values embedded in
    // the proof by the generated verifier. Callers supply only the circuit's 2.
    uint256 public constant EXPECTED_PUBLIC_INPUTS = 2;

    constructor(address _verifierAddress) {
        require(_verifierAddress != address(0), "Invalid verifier address");
        verifier = IVerifier(_verifierAddress);
    }

    function verifyAgeProof(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool) {
        require(_publicInputs.length == EXPECTED_PUBLIC_INPUTS, "Expected 2 public inputs");
        return verifier.verify(_proof, _publicInputs);
    }

    function buildDefaultPublicInputs(uint256 _currentYear) external pure returns (bytes32[] memory publicInputs) {
        require(_currentYear >= 2000 && _currentYear <= 2100, "Invalid current year range");

        publicInputs = new bytes32[](EXPECTED_PUBLIC_INPUTS);
        publicInputs[0] = bytes32(uint256(_currentYear));
        publicInputs[1] = bytes32(uint256(1));
    }
}
