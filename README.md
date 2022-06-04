<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="cryptozombies.png" alt="CryptoZombies"></a>
</p>

<h3 align="center">CryptoZombies</h3>

<div align="center">
</div>

---

<p align="center">CryptoZombies is a blockchain based game which i learned from <a href="https://cryptozombies.io" target="_blank">CryptoZombies</a> website which helped me with my solidity programming skills.
</p>

### Installing dependencies
```
yarn install
```

And set the environment variables for the following

```
ETHERSCAN_API_KEY=ABC123ABC123ABC123ABC123ABC123ABC1
RINKEBY="https://eth-rinkeby.alchemyapi.io/v2/<YOUR ALCHEMY KEY>"
PRIVATE_KEY=0xabc123abc123abc123abc123abc123abc123abc123abc123abc123abc123abc1
RINKEBY_VRF_COORDINATOR_V2_ADDRESS="0x6168499c0cFfCaCD319c818142124B7A15E857ab"
RINKEBY_CHAINLINK_SUB_ID=<Chainlink-vrf-subscription-id>
RINKEBY_CRYPTO_KITTIES_CONTRACT="0x16baF0dE678E52367adC69fD067E5eDd1D33e3bF"
RINKEBY_KEY_HASH="0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc"
```

## 🔧 Running the tests <a name = "tests"></a>


```
npx hardhat test
```

## 🚀 Deployment <a name = "deployment"></a>

```
npx hardhat deploy --network rinkeby --tags "cryptozombies"
```
