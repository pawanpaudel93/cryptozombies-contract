/* eslint-disable node/no-unpublished-import */
/* eslint-disable node/no-missing-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployVRFMock: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    const { getNamedAccounts } = hre;
    const { deploy, log } = hre.deployments;
    const { deployer } = await getNamedAccounts();
    const BASE_FEE = hre.ethers.utils.parseEther("0.1");
    const GAS_PRICE_LINK = 10 ** 9;
    const args = [BASE_FEE, GAS_PRICE_LINK];
    const VRFCoordinatorV2Mock = await deploy("VRFCoordinatorV2Mock", {
        from: deployer,
        log: true,
        args,
    });
    log(
        "You have deployed the vrfCoordinatorV2Mock contract to:",
        VRFCoordinatorV2Mock.address
    );
    const vrfCoordinatorV2Mock = await hre.ethers.getContract(
        "VRFCoordinatorV2Mock"
    );
    const subscriptionTx = await vrfCoordinatorV2Mock.createSubscription();
    const subscription = await subscriptionTx.wait();

    const subId = subscription.events?.find(
        (e: any) => e.event === "SubscriptionCreated"
    )?.args?.subId;
    const tx = await vrfCoordinatorV2Mock.fundSubscription(
        subId,
        hre.ethers.utils.parseEther("100")
    );
    await tx.wait();
    log(`Subscription ID: ${subId} funded.`);
};
export default deployVRFMock;
deployVRFMock.tags = ["all", "mocks"];
