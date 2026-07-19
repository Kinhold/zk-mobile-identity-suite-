# Kinhold Age Proof

A Noir circuit that proves a person is at least 19 without disclosing their
birth year, plus the generated UltraHonk Solidity verifier and a small wrapper.
This package is a prototype: circuit and contract unit checks are present, but a
real proof fixture has not yet been committed for end-to-end on-chain testing.

## Canonical workflow

Run every command from this `age-proof/` directory:

```bash
npm ci
npm run contracts:compile
npm test
npm run pack:check

# Requires nargo 1.0.0-beta.21
npm run circuit:compile
npm run circuit:test
```

The only Hardhat config is `hardhat.config.js`. Solidity sources live in
`contracts/`, tests in `contracts/test/`, and deployment code in
`contracts/scripts/`.

## Package contents

- `src/main.nr` — circuit with private `birth_year`, public `current_year`, and
  public return value `1`
- `src/tests.nr` — circuit boundary and invalid-input tests
- `contracts/verifier.sol` — generated `HonkVerifier` tied to the committed
  verification key
- `contracts/AgeProofVerifier.sol` — input-shape wrapper
- `contracts/test/verifier.test.js` — deployment and input-validation tests

`verifier.sol` is canonical generated code, not a mock. Regenerating it changes
the verification key and must be reviewed together with the circuit and a new
proof fixture.

## Public inputs

The verification key reports 10 total public inputs. Eight are recursive
pairing-point values carried inside the proof, and `HonkVerifier.verify`
therefore requires exactly two external values:

1. `current_year`
2. the circuit's public return value (`1`)

`buildDefaultPublicInputs(currentYear)` builds only this two-item external
array. It does not create or validate a proof.

## Proof generation

Use the versions recorded for the generated verifier:

- `nargo 1.0.0-beta.21`
- `bb 5.0.0-nightly.20260324`

```bash
nargo compile
nargo test
nargo execute
bb prove -b target/age_proof.json -w target/age_proof.gz \
  --write_vk -o target --oracle_hash keccak
bb verify -p target/proof -k target/vk
bb write_solidity_verifier -k target/vk -o contracts/verifier.sol
```

The Keccak transcript setting must match the Solidity verifier. Do not treat
passing deployment/input tests as proof verification: CI cannot claim E2E
verification until `proof`, `public_inputs`, and version metadata from the same
circuit/VK build are checked in as a fixture.

## Testnet deployment

Copy `.env.example` to `.env`, use a test-only key, then run:

```bash
npm run contracts:deploy:arbitrum-sepolia
# or
npm run contracts:deploy:ethereum-sepolia
```

Deployment uses the generated `HonkVerifier`, never a permissive placeholder.
See `SECURITY.md` for dependency-audit status.
