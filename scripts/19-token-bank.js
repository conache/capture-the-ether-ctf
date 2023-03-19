const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("TokenBankChallenge", deployer);
  const mainContract = await MainContract.deploy(attacker.address);

  const SimpleToken = await ethers.getContractFactory("SimpleERC223Token");
  const simpleToken = await SimpleToken.attach(mainContract.address);

  console.log(await simpleToken.balanceOf(deployer.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
