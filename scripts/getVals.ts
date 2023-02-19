require("dotenv").config();

async function main() {
  const QuadraticFundingFactory = await hre.ethers.getContractFactory(
    "QuadraticFunding"
  );
  const QuadraticFunding = await QuadraticFundingFactory.attach(
    "0x7D2FE3Dc467594a8Aa5398495c8998E636B7D7D0"
  );
  console.log(await QuadraticFunding.getTotalProjects());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
