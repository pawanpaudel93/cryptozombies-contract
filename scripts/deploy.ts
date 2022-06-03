import { deployments } from "hardhat";
async function main() {
    await deployments.fixture(["all"]);
    const cryptoZombies = await deployments.get("CryptoZombies");
    console.log(
        "Successfully deployed CryptoZombies to:",
        cryptoZombies.address
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
