const hre = require("hardhat");
const { ethers } = require("ethers");
const { deployContract } = require("./deploy-utils");

async function main() {
  const provider = new ethers.BrowserProvider(hre.network.provider);
  const signer = await provider.getSigner();

  async function deploy(contractName, args, libraries) {
    const contract = await deployContract(
      hre,
      signer,
      contractName,
      args,
      libraries,
    );
    console.log(`${contractName} deployed to ${await contract.getAddress()}`);
    return contract;
  }

  const transcriptLibrary = await deploy("ZKTranscriptLib");
  const verifier = await deploy("HonkVerifier", [], {
    ZKTranscriptLib: await transcriptLibrary.getAddress(),
  });
  await deploy("AgeProofVerifier", [await verifier.getAddress()]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
