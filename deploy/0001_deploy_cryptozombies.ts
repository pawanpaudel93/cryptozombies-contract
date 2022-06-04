/* eslint-disable node/no-unpublished-import */
/* eslint-disable node/no-missing-import */
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const DEVELOPMENT_NETWORKS = ["hardhat", "localhost"];

const deployCryptoZombies: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    const { getNamedAccounts, network, run } = hre;
    const { deploy, log } = hre.deployments;
    const { deployer } = await getNamedAccounts();
    let args = [];
    if (!DEVELOPMENT_NETWORKS.includes(network.name)) {
        args = [
            "CryptoZombies",
            "CRZ",
            parseInt(process.env.RINKEBY_CHAINLINK_SUB_ID!),
            process.env.RINKEBY_VRF_COORDINATOR_V2_ADDRESS!,
            process.env.RINKEBY_KEY_HASH!,
        ];
    } else {
        const vrfCoordinatorV2Mock = await hre.ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        args = [
            "CryptoZombies",
            "CRZ",
            1,
            vrfCoordinatorV2Mock.address,
            process.env.RINKEBY_KEY_HASH!,
        ];
    }

    const CryptoZombies = await deploy("CryptoZombies", {
        from: deployer,
        log: true,
        args,
    });
    log(
        "You have deployed the CryptoZombies contract to:",
        CryptoZombies.address
    );
    const cryptoZombies = await hre.ethers.getContract("CryptoZombies");
    if (network.name === "rinkeby") {
        const tx = await cryptoZombies.setKittyContractAddress(
            process.env.RINKEBY_CRYPTO_KITTIES_CONTRACT!
        );
        await tx.wait();
    }
    if (!DEVELOPMENT_NETWORKS.includes(network.name)) {
        // sleep for 60s
        await new Promise((resolve) => setTimeout(resolve, 60000));
        await run("verify:verify", {
            address: CryptoZombies.address,
            constructorArguments: args,
        });
    }
};
export default deployCryptoZombies;
deployCryptoZombies.tags = ["all", "cryptozombies", "mocks"];
