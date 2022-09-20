const { ethers } = require("hardhat");

const CHALLENGE_CONTRACT_ADDRESS = "0x60f8f911CB19feA9D0793CFB44Dfc21B31049798";

async function main() {
  const guessTheNumber = await ethers.getContractAt("GuessTheNumberChallenge", CHALLENGE_CONTRACT_ADDRESS);

  await guessTheNumber.guess(42, { value: ethers.utils.parseEther("1.0") });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
