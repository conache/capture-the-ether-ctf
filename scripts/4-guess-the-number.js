const { keccak256 } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const wantedHash = "0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365";
  const GuessTheNumberContract = await ethers.getContractFactory("GuessTheSecretNumberChallenge", deployer);
  const guessTheNumber = await GuessTheNumberContract.deploy({ value: ethers.utils.parseEther("1") });

  let secretNum = 0;
  for (let tryNo = 0; tryNo <= 2 ** 8 - 1; tryNo++) {
    if (keccak256(tryNo) !== wantedHash) {
      continue;
    }
    secretNum = tryNo;
    break;
  }

  console.log(
    "Is complete:",
    await guessTheNumber.isComplete(),
    "|",
    "Attacker balance (before the attack):",
    ethers.utils.formatEther(await ethers.provider.getBalance(attacker.address))
  );
  await guessTheNumber.connect(attacker).guess(secretNum, { value: ethers.utils.parseEther("1.0") });
  console.log(
    "Is complete:",
    await guessTheNumber.isComplete(),
    "|",
    "Attacker balance (after the attack):",
    ethers.utils.formatEther(await ethers.provider.getBalance(attacker.address))
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
