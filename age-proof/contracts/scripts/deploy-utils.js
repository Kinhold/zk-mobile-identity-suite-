const { ethers } = require("ethers");

function linkBytecode(artifact, libraries = {}) {
  let bytecode = artifact.bytecode.slice(2);

  for (const [sourceName, sourceReferences] of Object.entries(
    artifact.linkReferences,
  )) {
    for (const [libraryName, references] of Object.entries(sourceReferences)) {
      const address =
        libraries[`${sourceName}:${libraryName}`] ?? libraries[libraryName];
      if (address === undefined) {
        throw new Error(`Missing link address for ${sourceName}:${libraryName}`);
      }

      const normalizedAddress = ethers.getAddress(address).slice(2).toLowerCase();
      for (const { start, length } of references) {
        if (length !== 20) {
          throw new Error(`Unexpected link length for ${libraryName}: ${length}`);
        }
        const offset = start * 2;
        bytecode =
          bytecode.slice(0, offset) +
          normalizedAddress +
          bytecode.slice(offset + length * 2);
      }
    }
  }

  return `0x${bytecode}`;
}

async function deployContract(hre, signer, contractName, args = [], libraries) {
  const artifact = await hre.artifacts.readArtifact(contractName);
  const factory = new ethers.ContractFactory(
    artifact.abi,
    linkBytecode(artifact, libraries),
    signer,
  );
  const contract = await factory.deploy(...args);
  await contract.waitForDeployment();
  return contract;
}

module.exports = { deployContract, linkBytecode };
