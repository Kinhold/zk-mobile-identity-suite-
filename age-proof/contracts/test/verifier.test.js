const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AgeProofVerifier", function () {
  let Verifier;
  let verifier;
  let AgeProofVerifier;
  let ageProofVerifier;

  beforeEach(async function () {
    // Deploy the Verifier contract (placeholder for the actual generated verifier)
    Verifier = await ethers.getContractFactory("Verifier");
    verifier = await Verifier.deploy();
    await verifier.waitForDeployment();

    // Deploy the AgeProofVerifier contract
    AgeProofVerifier = await ethers.getContractFactory("AgeProofVerifier");
    ageProofVerifier = await AgeProofVerifier.deploy(verifier.target);
    await ageProofVerifier.waitForDeployment();
  });

  it("Should deploy the Verifier and AgeProofVerifier contracts", async function () {
    expect(verifier.target).to.not.be.null;
    expect(ageProofVerifier.target).to.not.be.null;
  });

  // Add more tests here once the actual proof generation and verification logic is integrated
  // For now, this just checks deployment.
});
