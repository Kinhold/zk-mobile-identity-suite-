# Security notes

## Dependency audit

As of 2026-07-14:

- `npm audit --omit=dev`: **0 vulnerabilities**
- full `npm audit`: **16 development-only findings** (10 low, 3 moderate,
  3 high), down from 43 after replacing `hardhat-toolbox` with the minimal
  `hardhat`, `ethers`, and `dotenv` toolchain

The remaining findings are transitive dependencies of Hardhat 2.28.6. The high
findings are in `serialize-javascript` through Mocha, `tmp` through the bundled
Solidity compiler, and `undici` through Hardhat. `npm audit fix` cannot remove
them within Hardhat 2's declared dependency ranges. Audit recommends Hardhat
3.9.1, which is a breaking ESM/plugin/config migration and was deliberately not
force-installed in this hardening pass.

Hardhat and all other direct development dependencies are exact-pinned in
`package-lock.json`. Keep Hardhat execution restricted to trusted repository
code and trusted RPC/compiler endpoints. Reassess a Hardhat 3 migration
separately rather than applying `npm audit fix --force`.

## Proof-verification status

`contracts/verifier.sol` is generated cryptographic code, not a mock. Contract
tests deploy it and confirm wrapper/input behavior, but there is no committed
proof fixture. Until a proof generated from the same circuit, verification key,
and transcript settings is tested on-chain, this package must not claim
end-to-end proof verification.

Never commit private keys, production witness data, or an `.env` file.
