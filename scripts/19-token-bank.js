const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const AttackerContract = await ethers.getContractFactory("TokenBankAttacker", deployer);
  const attackerContract = await AttackerContract.deploy();

  const BankContract = await ethers.getContractFactory("TokenBankChallenge", deployer);
  const bankContract = await BankContract.deploy(attackerContract.address);

  const SimpleToken = await ethers.getContractFactory("SimpleERC223Token");
  const simpleToken = await SimpleToken.attach(await bankContract.token());

  await attackerContract.setBankContract(bankContract.address);
  await attackerContract.attack();

  console.log("Is complete:", await bankContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
