import { deployCryptoZombies } from "./utils";

async function main() {
  const { cryptoZombies } = await deployCryptoZombies();
  console.log("CryptoZombies deployed to:", cryptoZombies.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
