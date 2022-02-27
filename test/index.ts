import { expect } from "chai";
import { ethers } from "hardhat";

describe("CryptoZombies", function () {
  it("Should deploy and create a random zombie", async function () {
    const [account] = await ethers.getSigners();
    const CryptoZombies = await ethers.getContractFactory("CryptoZombies");
    const cryptoZombies = await CryptoZombies.deploy("CryptoZombies", "CRZ");
    await cryptoZombies.deployed();
    await cryptoZombies.createRandomZombie("test");

    expect(cryptoZombies.address).to.be.a("string");
    expect((await cryptoZombies.zombies(0))[0]).equal("test");
    expect(await cryptoZombies.balanceOf(account.address)).equal(1);
  });
});
