# Age Proof Circuit

This project demonstrates a Noir circuit to prove that an individual's age is greater than 18 without revealing their exact birth year. It is part of the ZK Mobile Identity Suite.

## Project Structure

```
age-proof/
├── Nargo.toml
├── src/
│   ├── main.nr
│   └── tests.nr
├── benchmark.sh
├── contracts/
│   ├── Verifier.sol             // Placeholder for device-exported verifier
│   ├── AgeProofVerifier.sol     // Wrapper contract for age proof verification
│   └── test/verifier.test.js    // Basic tests for the verifier contracts
├── hardhat.config.js
├── package.json
├── scripts/deploy.js
├── .env.example
└── .github/workflows/ci.yml
```

## Core Logic (`src/main.nr`)

The `main.nr` file contains the Noir circuit that takes `birth_year` (private input) and `current_year` (public input) to assert that `age >= 19`.

## Unit Tests (`src/tests.nr`)

Comprehensive unit tests are provided to cover various scenarios, including passing cases, exact boundary failures, underage failures, and future birth year failures.

## Verified Command Sequence (Device-Only)

**Note:** Due to sandbox SRS/memory constraints, `bb prove` and `bb verify` cannot be executed within the sandbox environment and must be run on a physical device. The following sequence has been validated on a physical device.

To compile, test, generate witness, prove, and verify the circuit, follow these steps in your Termux environment after logging into `proot-distro login ubuntu` and ensuring `nargo` and `bb` are in your PATH (e.g., by adding `export PATH=$PATH:/data/data/com.termux/files/home/.bb` to your `.bashrc`):

```bash
cd ~/zk-mobile-identity-suite-/age-proof

# 1. Compile and test (sandbox-safe)
nargo compile
nargo test        # 6/6 tests pass
nargo execute     # generates target/age_proof.gz

# Single-step: generates proof, VK, public_inputs, and vk_hash as FILES in target/
bb prove -b target/age_proof.json -w target/age_proof.gz --write_vk -o target --oracle_hash keccak

# Verify
bb verify -p target/proof -k target/vk
# Expected: "Proof verified successfully"
```

## Notes on `bb` Version Compatibility

The sandbox environment encountered persistent "Length is too large" errors when attempting to use `bb` versions compatible with `nargo 1.0.0-beta.21`. This is due to an ACIR version mismatch. The provided command sequence is validated to work on a physical device with the specified `nargo` and `bb` versions (`nargo 1.0.0-beta.21` and `bb 5.0.0-nightly.20260324`).

## Phase 2: Export Solidity Verifier & Testnet Deployment Setup

This phase focuses on bridging the Noir ZK proof to the Ethereum ecosystem by exporting a Solidity verifier and setting up a deployment pipeline.

### 1. Exporting the Verifier (Device-Only)

**Do NOT attempt to run `bb write_solidity_verifier` in the sandbox — it may fail due to SRS constraints.** This step must be performed on your physical device.

From your device, navigate to the `age-proof` directory and execute the following command:

```bash
cd ~/zk-mobile-identity-suite-/age-proof
mkdir -p contracts
bb write_vk -b target/age_proof.json -o target/vk_keccak --oracle_hash keccak
bb write_solidity_verifier -k target/vk_keccak/vk -o contracts/Verifier.sol
```

This command will generate the `Verifier.sol` contract in the `contracts/` directory, which will be used by the `AgeProofVerifier.sol` wrapper contract.

### 2. Deploying to Testnet

This project uses Hardhat for smart contract development and deployment. You can deploy the `AgeProofVerifier` to a testnet like Arbitrum Sepolia or Ethereum Sepolia.

#### Setup:

1.  **Install dependencies:** Ensure you have Node.js and npm installed. Navigate to the `age-proof` directory and install the Hardhat dependencies:
    ```bash
    cd ~/zk-mobile-identity-suite-/age-proof
    npm install
    ```
2.  **Configure `.env`:** Copy `.env.example` to `.env` and fill in your RPC URLs and private key. You can obtain RPC URLs from providers like Alchemy or Infura, and a private key from your wallet (use a testnet account with no real funds).
    ```bash
    cp .env.example .env
    # Open .env and add your details
    ```

#### Deployment:

To deploy the contracts to Arbitrum Sepolia, run:

```bash
npx hardhat run scripts/deploy.js --network arbitrumSepolia
```

Replace `arbitrumSepolia` with `ethereumSepolia` if you wish to deploy to Ethereum Sepolia.

### 3. Submitting a Proof for On-Chain Verification

Once the `AgeProofVerifier` contract is deployed, you can submit a generated proof for on-chain verification. This involves:

1.  **Generate a proof** on your device using the `bb prove` command as described in the "Verified Command Sequence" section.
2.  **Extract the proof and public inputs** from the generated files (`target/proof` and `target/public_inputs`).
3.  **Call the `verifyAgeProof` function** on your deployed `AgeProofVerifier` contract, passing the proof and the `current_year` as public input. This can be done via a custom script, Hardhat task, or a web interface interacting with your contract.

Example (conceptual, requires a script to read proof and public inputs):

```javascript
// Example using ethers.js (within a Hardhat script or test)
const ageProofVerifierAddress = "YOUR_DEPLOYED_AGE_PROOF_VERIFIER_ADDRESS";
const ageProofVerifier = await ethers.getContractAt("AgeProofVerifier", ageProofVerifierAddress);

const proof = "0x..."; // Your generated proof as a hex string
const currentYear = 2026; // The current year used in the proof

const isProofValid = await ageProofVerifier.verifyAgeProof(proof, currentYear);
console.log("Proof is valid on-chain:", isProofValid);
```

## GitHub Action

A GitHub Action (`.github/workflows/ci.yml`) is configured to run `nargo compile`, `nargo test`, and check for the presence of contract files on every push and pull request. This ensures the Noir circuit and contract scaffold remain functional and correctly structured.
