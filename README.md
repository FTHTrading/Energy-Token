# FTHTrading // Energy-Token Ecosystem
> **Decentralized RWA Energy Infrastructure & P2P Escrow System**

[![Solidity Version](https://img.shields.io/badge/solidity-0.8.24-brightgreen.svg?style=flat-square)](https://soliditylang.org/)
[![Framework](https://img.shields.io/badge/Framework-Foundry-orange.svg?style=flat-square)](https://book.getfoundry.sh/)
[![Platform](https://img.shields.io/badge/Chain-BNB_Testnet-blue.svg?style=flat-square)]()
[![DAO Controlled](https://img.shields.io/badge/Governance-DAO--Timelocked-purple.svg?style=flat-square)]()

---

## Repository Layout

```
Energy-Token/
├── contracts/                          # Foundry smart contract workspace
│   ├── src/                            # Core contracts (UNYE, NFT, Distributor, Escrow, DAO)
│   ├── script/Deploy.s.sol             # Full ecosystem deployment + DAO handoff
│   ├── test/UnykornEnergyToken.t.sol   # Foundry test suite (9 tests)
│   └── foundry.toml
├── oracle-telemetry/mock-inverter.js   # Local SolarEdge/Enphase telemetry simulator
├── marketing-and-docs/                   # Whitepaper, BNB testnet deploy guide, launch kit
└── frontend/                           # Next.js dApp scaffold
```

---

## Quick Start

```bash
git clone https://github.com/FTHTrading/Energy-Token.git
cd Energy-Token/contracts

# Install forge-std if lib is incomplete after clone
forge install foundry-rs/forge-std --no-commit

# OpenZeppelin + Chainlink npm deps
npm install

# Build and test
forge build
forge test -vvv
```

Frontend:

```bash
cd ../frontend
npm install
npm run dev
```

---

## Core Contracts

| Contract | Purpose |
|----------|----------|
| `UnykornEnergyToken.sol` | 250M cap ERC20 (UNYE), UUPS, transfer tax, voting |
| `SolarSetupNFT.sol` | DePIN hardware registry (UNY-SOLAR) |
| `SolarRewardsDistributor.sol` | Chainlink Functions kWh verification + dynamic mint |
| `P2PEnergyEscrow.sol` | P2P local energy trading escrow |
| `UnykornGovernor.sol` + `UnykornTimelock.sol` | DAO governance |

**Reward rate:** 1 UNYE per 5 kWh verified  
**Genesis supply:** 50M UNYE to treasury

---

## BNB Testnet Deployment

```powershell
cd contracts
$env:PRIVATE_KEY="<DEPLOYER_KEY>"
$env:TREASURY_ADDRESS="<TREASURY>"
$env:ARBITRATOR_ADDRESS="<ARBITRATOR>"
forge script script/Deploy.s.sol `
  --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 `
  --broadcast --verify
```

Faucet: https://testnet.bnbchain.org/faucet-smart

See `marketing-and-docs/DEPLOYMENT_BNB_TESTNET.md` for predicted addresses and launch kit.

---

*FTHTrading — Copyright 2026*
