import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { deployCryptoZombies } from "../scripts/utils";

const zombieNames = ["Zombie 1", "Zombie 2"];

describe("CryptoZombies", function () {
  let contractInstance: Contract;
  let vrfCoordinator: Contract | undefined;
  let alice: Signer, bob: Signer;
  let aliceAddress: string, bobAddress: string;

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners();
    const { cryptoZombies, vrfCoordinatorV2Mock } = await deployCryptoZombies();
    contractInstance = cryptoZombies;
    vrfCoordinator = vrfCoordinatorV2Mock;
    aliceAddress = await alice.getAddress();
    bobAddress = await bob.getAddress();

    const createTx = await contractInstance.createRandomZombie(zombieNames[0]);
    let receipt = await createTx.wait();

    const requestId = receipt.events?.find(
      (e: any) => e.event === "RandomRequest"
    )?.args?.requestId;

    const tx = await vrfCoordinator!.fulfillRandomWords(
      requestId,
      contractInstance.address
    );
    receipt = await tx.wait();
    expect(
      receipt.events.find((e: any) => e.event === "RandomWordsFulfilled").args
        .success
    ).to.equal(true);
  });

  afterEach(async () => {
    await contractInstance.kill();
  });

  it("Should create a random zombie", async function () {
    expect(contractInstance.address).to.be.a("string");
    expect((await contractInstance.zombies(0))[0]).equal(zombieNames[0]);
    expect(await contractInstance.balanceOf(aliceAddress)).equal(1);
  });

  it("should not allow two zombies", async () => {
    await expect(contractInstance.createRandomZombie(zombieNames[1])).to.be
      .reverted;
  });

  context("with the single-step transfer scenario", async () => {
    it("should transfer a zombie", async () => {
      const zombieId = 0;
      await contractInstance.transferFrom(aliceAddress, bobAddress, zombieId);
      const newOwner = await contractInstance.ownerOf(zombieId);
      expect(newOwner).to.equal(bobAddress);
    });
  });

  context("with the two-step transfer scenario", async () => {
    it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
      const zombieId = 0;
      await contractInstance.approve(bobAddress, zombieId);
      await contractInstance
        .connect(bob)
        .transferFrom(alice.getAddress(), bob.getAddress(), zombieId);
      const newOwner = await contractInstance.ownerOf(zombieId);
      expect(newOwner).to.equal(bobAddress);
    });

    it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
      const zombieId = 0;
      await contractInstance.approve(bobAddress, zombieId);
      await contractInstance.transferFrom(aliceAddress, bobAddress, zombieId);
      const newOwner = await contractInstance.ownerOf(zombieId);
      expect(newOwner).to.equal(bobAddress);
    });
  });

  it("zombies should be able to attack another zombie", async () => {
    const firstZombieId = 0;
    const secondZombieId = 1;

    const createTx = await contractInstance
      .connect(bob)
      .createRandomZombie(zombieNames[1]);
    let receipt = await createTx.wait();
    const requestId = receipt.events?.find(
      (e: any) => e.event === "RandomRequest"
    )?.args?.requestId;

    const tx = await vrfCoordinator!
      .connect(bob)
      .fulfillRandomWords(requestId, contractInstance.address);
    receipt = await tx.wait();

    expect(
      receipt.events.find((e: any) => e.event === "RandomWordsFulfilled").args
        .success
    ).to.equal(true);

    expect(await contractInstance.ownerOf(secondZombieId)).to.equal(bobAddress);

    const oneDay =
      (await (
        await ethers.provider.getBlock(await ethers.provider.getBlockNumber())
      ).timestamp) +
      24 * 60 * 60;
    await ethers.provider.send("evm_setNextBlockTimestamp", [oneDay]);
    await ethers.provider.send("evm_mine", []);

    const attackTx = await contractInstance.attack(
      firstZombieId,
      secondZombieId
    );
    receipt = await attackTx.wait();
    const { attackerId, targetId } = receipt.events?.find(
      (e: any) => e.event === "Attacked"
    )?.args;
    expect(attackerId).to.equal(firstZombieId);
    expect(targetId).to.equal(secondZombieId);
  });
});
