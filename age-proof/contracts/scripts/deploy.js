const hre = require("hardhat");

async function main() {
  const Verifier = await hre.ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy();
  await verifier.waitForDeployment();
  console.log(`Verifier deployed to ${verifier.target}`);

  const AgeProofVerifier = await hre.ethers.getContractFactory("AgeProofVerifier");
  const ageProofVerifier = await AgeProofVerifier.deploy(verifier.target);
  await ageProofVerifier.waitForDeployment();
  console.log(`AgeProofVerifier deployed to ${ageProofVerifier.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
