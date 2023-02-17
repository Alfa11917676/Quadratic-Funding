const { ethers } = require("hardhat");
const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const QuadraticFundingFactory = await hre.ethers.getContractFactory(
    "QuadraticFunding"
  );
  const QuadraticFunding = await QuadraticFundingFactory.deploy();

  console.log(`Deployed to ${QuadraticFunding.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
