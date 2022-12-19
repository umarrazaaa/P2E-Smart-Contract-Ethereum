const hre = require("hardhat");

async function main() {


	const [deployer] = await ethers.getSigners();

	console.log(
	"Deploying contracts with the account:",
	deployer.address
	);

	console.log("Account balance:", (await deployer.getBalance()).toString());

  const Lock = await hre.ethers.getContractFactory("InvoFlip");
  const lock = await Lock.deploy("0x1fc5E590613928464a2836BDd276E4cBD5137162");

  await lock.deployed();

  console.log(
    `MintsClub Minting Contract Deployed to ${lock.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});