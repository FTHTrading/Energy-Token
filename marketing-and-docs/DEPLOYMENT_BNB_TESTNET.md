# BNB Testnet Deployment — Unykorn Energy

**Chain:** BNB Smart Chain Testnet (chainId 97)  
**RPC:** `https://data-seed-prebsc-1-s1.binance.org:8545`  
**Deployer:** `0x4A28aDDA36eCAE7A170a36c4195e10257114A7B2`  
**Status:** Simulated only — deployer balance **0 tBNB** (fund before `--broadcast`)

## Gas estimate (dry-run)

| Metric | Value |
|--------|-------|
| Estimated gas | ~19,578,003 |
| Estimated cost | **~0.00196 BNB** |
| Recommended faucet request | **0.01 tBNB** (buffer for verify) |

## Faucet

https://testnet.bnbchain.org/faucet-smart

## Deploy command

```powershell
cd contracts
$env:PRIVATE_KEY = "<DEPLOYER_PRIVATE_KEY>"
$env:TREASURY_ADDRESS = "0x4A28aDDA36eCAE7A170a36c4195e10257114A7B2"
$env:ARBITRATOR_ADDRESS = "0x4A28aDDA36eCAE7A170a36c4195e10257114A7B2"
forge script script/Deploy.s.sol `
  --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 `
  --broadcast `
  --verify
```

## Post-deploy verification

```powershell
.\marketing-and-docs\social-campaigns\TESTNET_VERIFY.ps1 `
  -TokenAddress <UNYE_PROXY> `
  -NftAddress <NFT_PROXY> `
  -DistributorAddress <DISTRIBUTOR_PROXY>
```

## Chainlink (BNB testnet)

- Functions Router: `0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C`
- Set `CHAINLINK_SUB_ID` env var before deploy if you have a subscription

## Token economics

- Reward rate: **1 UNYE per 5 kWh** verified
- Max supply: 250M UNYE
- Genesis mint: 50M UNYE to treasury
