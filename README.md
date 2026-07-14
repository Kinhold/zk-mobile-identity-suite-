# Kinhold ZK Mobile Identity Suite

Device-first identity proofs for the Kinhold umbrella.

This repository is the mobile identity lane for `kinhold.io`. Today it ships one real package:

- `age-proof/` — a Noir age-gate circuit with Hardhat contract scaffolding for on-chain verification

## Current package status

| Package | Status | Notes |
| --- | --- | --- |
| `age-proof` | packageable prototype | Noir circuit, generated Honk verifier, wrapper and contract tests |

## What is here today

- Noir circuit proving `age >= 19` without revealing birth year
- Hardhat project for deploying the generated Honk verifier and wrapper contract
- Device-first proving notes for Termux / mobile workflows

## What is not here yet

- broader identity suite circuits
- mobile app shell
- production deployment pipeline
- end-to-end on-chain verification fixtures checked into CI

## Packaging intent for kinhold.io

This repo should package under Kinhold as:

- **Product surface:** ZK Mobile Identity
- **First artifact:** Age Proof
- **Future artifacts:** device-backed claims, document traits, selective disclosure lanes

## Next release bar

Before this repo is promoted on `kinhold.io`, it should have:

1. a real proof fixture checked against the committed generated verifier
2. reproducible verifier regeneration with pinned Noir/Barretenberg tooling
3. a reviewed production deployment configuration

## Canonical package workflow

```bash
cd age-proof
npm ci
npm run contracts:compile
npm test
npm run pack:check
```

See `age-proof/README.md` for circuit commands, deployment, public-input layout,
and the explicit end-to-end testing gap.
