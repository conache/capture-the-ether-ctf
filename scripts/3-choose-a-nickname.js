const { ethers, web3 } = require("hardhat");

const CHALLENGE_CONTRACT_ADDRESS = "0x71c46Ed333C35e4E6c62D32dc7C8F00D125b4fee";
async function main() {
  const captureTheEther = await ethers.getContractAt("CaptureTheEther", CHALLENGE_CONTRACT_ADDRESS);

  const nickname = web3.utils.asciiToHex("chewy.chip");

  await captureTheEther.setNickname(nickname + "0".repeat(66 - nickname.length));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
