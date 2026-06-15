# Age Proof Circuit

This project demonstrates a Noir circuit to prove that an individual's age is greater than 18 without revealing their exact birth year. It is part of the ZK Mobile Identity Suite.

## Project Structure

```
age-proof/
├── Nargo.toml
├── src/
│   ├── main.nr
│   └── tests.nr
└── benchmark.sh
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
bb prove -b target/age_proof.json -w target/age_proof.gz --write_vk -o target

# Verify
bb verify -p target/proof -k target/vk
# Expected: "Proof verified successfully"
```

## Notes on `bb` Version Compatibility

The sandbox environment encountered persistent "Length is too large" errors when attempting to use `bb` versions compatible with `nargo 1.0.0-beta.21`. This is due to an ACIR version mismatch. The provided command sequence is validated to work on a physical device with the specified `nargo` and `bb` versions (`nargo 1.0.0-beta.21` and `bb 5.0.0-nightly.20260324`).
