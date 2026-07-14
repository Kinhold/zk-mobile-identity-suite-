const assert = require("node:assert/strict");
const hre = require("hardhat");
const { ethers } = require("ethers");
const { deployContract } = require("../scripts/deploy-utils");

describe("AgeProofVerifier", function () {
  let signer;
  let transcriptLibrary;
  let verifier;
  let ageProofVerifier;

  beforeEach(async function () {
    const provider = new ethers.BrowserProvider(hre.network.provider);
    signer = await provider.getSigner();

    transcriptLibrary = await deployContract(
      hre,
      signer,
      "ZKTranscriptLib",
    );
    verifier = await deployContract(hre, signer, "HonkVerifier", [], {
      ZKTranscriptLib: await transcriptLibrary.getAddress(),
    });
    ageProofVerifier = await deployContract(
      hre,
      signer,
      "AgeProofVerifier",
      [await verifier.getAddress()],
    );
  });

  it("deploys the Honk verifier and AgeProofVerifier wrapper", async function () {
    assert.notEqual(await verifier.getAddress(), ethers.ZeroAddress);
    assert.equal(
      await ageProofVerifier.verifier(),
      await verifier.getAddress(),
    );
  });

  it("forwards two inputs to the real verifier", async function () {
    await assert.rejects(
      ageProofVerifier.verifyAgeProof("0x", [ethers.ZeroHash, ethers.ZeroHash]),
      (error) => {
        assert.equal(error.code, "CALL_EXCEPTION");
        assert.equal(
          error.data.slice(0, 10),
          ethers
            .id("ProofLengthWrongWithLogN(uint256,uint256,uint256)")
            .slice(0, 10),
        );
        return true;
      },
    );
  });

  it("rejects malformed public-input length in the wrapper", async function () {
    await assert.rejects(
      ageProofVerifier.verifyAgeProof("0x", [ethers.ZeroHash]),
      /Expected 2 public inputs/,
    );
  });

  it("constructs the two external circuit inputs", async function () {
    const publicInputs = await ageProofVerifier.buildDefaultPublicInputs(2026);

    assert.deepEqual(Array.from(publicInputs), [
      ethers.zeroPadValue(ethers.toBeHex(2026), 32),
      ethers.zeroPadValue(ethers.toBeHex(1), 32),
    ]);
    assert.equal(await ageProofVerifier.EXPECTED_PUBLIC_INPUTS(), 2n);
  });

  it("rejects an out-of-range current year", async function () {
    await assert.rejects(
      ageProofVerifier.buildDefaultPublicInputs(1999),
      /Invalid current year range/,
    );
  });

  it("rejects a zero verifier address", async function () {
    await assert.rejects(
      deployContract(
        hre,
        signer,
        "AgeProofVerifier",
        [ethers.ZeroAddress],
      ),
      /Invalid verifier address/,
    );
  });
});
