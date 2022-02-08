import { expect } from "chai";
import { ethers } from "hardhat";

describe("CryptoZombies", function () {
  it("Should deploy and return contract address", async function () {
    const CryptoZombies = await ethers.getContractFactory("CryptoZombies");
    const cryptoZombies = await CryptoZombies.deploy();
    await cryptoZombies.deployed();

    expect(cryptoZombies.address).to.be.a("string");
  });
});
