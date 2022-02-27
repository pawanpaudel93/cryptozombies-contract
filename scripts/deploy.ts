// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, network } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const CryptoZombies = await ethers.getContractFactory("CryptoZombies");
  const cryptoZombies = await CryptoZombies.deploy("CryptoZombies", "CRZ");

  await cryptoZombies.deployed();
  if (network.name === "rinkeby") {
    const tx = await cryptoZombies.setKittyContractAddress(
      "0x16baF0dE678E52367adC69fD067E5eDd1D33e3bF"
    );
    await tx.wait();
  }

  console.log("CryptoZombies deployed to:", cryptoZombies.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
