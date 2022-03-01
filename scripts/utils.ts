import { Contract } from "ethers";
import { ethers, network } from "hardhat";

export const deployMocks = async () => {
  // console.log("Deploying mocks...");
  const VRFCoordinatorV2Mock = await ethers.getContractFactory(
    "VRFCoordinatorV2Mock"
  );
  const BASE_FEE = ethers.utils.parseEther("0.1");
  const GAS_PRICE_LINK = 10 ** 9;
  const vrfCoordinatorV2Mock = await VRFCoordinatorV2Mock.deploy(
    BASE_FEE,
    GAS_PRICE_LINK
  );
  await vrfCoordinatorV2Mock.deployed();
  return vrfCoordinatorV2Mock;
};

export const deploy = async (
  subscriptionId: number,
  vrfCoordinatorV2Address: string
) => {
  const CryptoZombies = await ethers.getContractFactory("CryptoZombies");
  const cryptoZombies = await CryptoZombies.deploy(
    "CryptoZombies",
    "CRZ",
    subscriptionId,
    vrfCoordinatorV2Address
  );

  await cryptoZombies.deployed();
  if (network.name === "rinkeby") {
    const tx = await cryptoZombies.setKittyContractAddress(
      "0x16baF0dE678E52367adC69fD067E5eDd1D33e3bF"
    );
    await tx.wait();
  }
  return cryptoZombies;
};

export const deployCryptoZombies = async () => {
  let cryptoZombies: Contract;

  if (network.name === "localhost" || network.name === "hardhat") {
    const vrfCoordinatorV2Mock = await deployMocks();
    const subscriptionTx = await vrfCoordinatorV2Mock.createSubscription();
    const subscription = await subscriptionTx.wait();

    const subId = subscription.events?.find(
      (e: any) => e.event === "SubscriptionCreated"
    )?.args?.subId;
    // console.log("Subscription created:", subId.toString());
    const tx = await vrfCoordinatorV2Mock.fundSubscription(
      subId,
      ethers.utils.parseEther("100")
    );
    await tx.wait();

    cryptoZombies = await deploy(subId, vrfCoordinatorV2Mock.address);
    return { cryptoZombies, vrfCoordinatorV2Mock };
  } else {
    cryptoZombies = await deploy(
      693,
      "0x6168499c0cFfCaCD319c818142124B7A15E857ab"
    );
    return { cryptoZombies };
  }
};
