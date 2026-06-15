// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Verifier.sol";

contract AgeProofVerifier {
    IVerifier public immutable verifier;

    constructor(address _verifierAddress) {
        verifier = IVerifier(_verifierAddress);
    }

    function verifyAgeProof(bytes calldata _proof, uint256 _currentYear) public view returns (bool) {
        // The public inputs for the age_proof circuit are [current_year, 1 (circuit output)]
        // The circuit asserts that age >= 19. If the assertion passes, the circuit returns 1.
        // So, we expect the second public input to be 1.
        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = bytes32(uint256(_currentYear));
        publicInputs[1] = bytes32(uint256(1)); // Expected circuit output for a valid proof

        bool isValid = verifier.verify(_proof, publicInputs);

        // Additional check: ensure currentYear is reasonable (e.g., not in the distant past or future)
        // This is a basic sanity check and can be expanded.
        require(_currentYear >= 2000 && _currentYear <= 2100, "Invalid current year range");

        return isValid;
    }
}
