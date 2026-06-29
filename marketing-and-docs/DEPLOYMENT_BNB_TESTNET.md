# BNB Testnet Deployment

**RPC:** https://data-seed-prebsc-1-s1.binance.org:8545

| Contract | Address |
|----------|---------|
| UNYE Token | 0x82905Ce761fA285D3B92e919642daB2cE8fc170e |
| Solar NFT | 0x5Cc673A7f0317bCa877065745b63C6b3BC7Ee6D3 |
| Distributor | 0x996ECE23EC589bC6A23c782d82A7c2C6F4D6d7fF |
| Escrow | 0xE8e2E45F204904283E104825dEA376035d8524a9 |

```powershell
cd contracts
forge script script/Deploy.s.sol --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 --broadcast --verify
```

Faucet: https://testnet.bnbchain.org/faucet-smart
