# Solidity contracts

This directory is source-only. Run Hardhat from the `age-proof/` package root:

```bash
npm run contracts:compile
npm test
npm run contracts:deploy:arbitrum-sepolia
```

- `verifier.sol` is the canonical generated `HonkVerifier`.
- `AgeProofVerifier.sol` validates the two caller-supplied circuit inputs and
  delegates cryptographic verification.
- `scripts/deploy.js` deploys the generated transcript library, links and
  deploys `HonkVerifier`, then deploys the wrapper.
- `test/verifier.test.js` tests deployment and input handling only.

Although the generated verification key declares 10 public inputs, its verifier
subtracts eight pairing-point inputs embedded in the proof. The external
`verify` call accepts exactly two inputs (`current_year` and public output `1`).

There is no committed real proof fixture. These tests intentionally do not use
a fake verifier or claim end-to-end proof verification.
