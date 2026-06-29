# 🦄 FTHTrading // Energy-Token Ecosystem
> **State-of-the-Art, Decentralized RWA Energy Infrastructure & P2P Escrow System**

[![Solidity Version](https://img.shields.io/badge/solidity-0.8.24-brightgreen.svg?style=flat-square)](https://soliditylang.org/)
[![Framework](https://img.shields.io/badge/Framework-Foundry-orange.svg?style=flat-square)](https://book.getfoundry.sh/)
[![Platform](https://img.shields.io/badge/Chain-Multi--Chain_(BNB/Base/Polygon)-blue.svg?style=flat-square)]()
[![DAO Controlled](https://img.shields.io/badge/Governance-DAO--Timelocked-purple.svg?style=flat-square)]()

---

## 🎨 System Architecture Navigation Map

Here is the color-coded architectural breakdown of the **FTHTrading Energy-Token** repository. Each layer represents a distinct system responsibility with dedicated access controls.

| Category | Component Badge | Directory / Files | Purpose & Scope |
| :--- | :--- | :--- | :--- |
| **Core Economy** | ![Core Token](https://img.shields.io/badge/Core_Token-28a745?style=flat-square&logo=ethereum&logoColor=white) | [`src/UnykornEnergyToken.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/UnykornEnergyToken.sol) | Fixed-supply 250M ERC20 token with UUPS upgradeability, customizable transfer fees (0-2%), and voting delegation logic. |
| **Hardware Registry** | ![DePIN NFT](https://img.shields.io/badge/DePIN_NFT-007bff?style=flat-square&logo=smartthings&logoColor=white) | [`src/SolarSetupNFT.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/SolarSetupNFT.sol) | ERC721 hardware proof registry. Maps token IDs to physical inverters (SolarEdge/Enphase brand and watt capacity). |
| **Oracle Consensus** | ![Rewards Distributor](https://img.shields.io/badge/Oracle_Rewards-ffc107?style=flat-square&logo=chainlink&logoColor=white) | [`src/SolarRewardsDistributor.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/SolarRewardsDistributor.sol) | Gated claims center. Uses ECDSA signatures to verify kWh telemetry from API nodes and dispense rewards. |
| **Trading & Escrow** | ![P2P Escrow](https://img.shields.io/badge/P2P_Escrow-fd7e14?style=flat-square&logo=data-dglove&logoColor=white) | [`src/P2PEnergyEscrow.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/P2PEnergyEscrow.sol) | P2P local grid matching engine. Lock payment tokens in escrow, release on buyer confirmation, or request mediator arbitration. |
| **Governance Control** | ![DAO Governor](https://img.shields.io/badge/DAO_Governor-6f42c1?style=flat-square&logo=governor&logoColor=white) | [`src/UnykornGovernor.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/UnykornGovernor.sol) <br> [`src/UnykornTimelock.sol`](file:///C:/Users/Kevan/.gemini/antigravity-ide/scratch/unykorn-energy-token/src/UnykornTimelock.sol) | OpenZeppelin v5 based Governor and Timelock. Restricts admin setters (rates, taxes) to proposal voting. |

---

## 📂 Repository Layout

```directory
Energy-Token/
├── contracts/                          # Foundry smart contract workspace
│   ├── src/                            # Core contracts (UNYE, NFT, Distributor, Escrow, DAO)
│   ├── script/Deploy.s.sol             # Full ecosystem deployment + DAO handoff
│   ├── test/                           # Foundry test suite (9 tests)
│   └── foundry.toml
├── oracle-telemetry/
│   └── mock-inverter.js                # Local SolarEdge/Enphase telemetry simulator
├── marketing-and-docs/
│   ├── WHITEPAPER.md
│   └── social-campaigns/               # X thread, Telegram, testnet verify script
└── frontend/                           # Next.js dApp scaffold (wagmi integration pending)
```

---

## 🟩 Layer 1: Core Token (UNYE)
- **Token Name**: Unykorn Energy Token
- **Token Symbol**: `UNYE`
- **Supply Ceiling**: 250,000,000 (Fixed Cap)
- **Custom Hook**: `_update` logic intercepts transfers to charge a tax of 0% - 2% (customizable by DAO/Owner) and route it back to the rewards treasury. 
- **Tax Whitelisting**: System contracts (Escrow, Distributor) are whitelisted from paying taxes during trading or distribution cycles.

## 🟦 Layer 2: DePIN Solar Setup Registry (NFT)
- **Token Name**: Unykorn Solar Setup NFT
- **Token Symbol**: `UNY-SOLAR`
- **Telemetric Mapping**: Maps `tokenId` to `InverterMetadata`:
  ```solidity
  struct InverterMetadata {
      string inverterId;      // Brand Serial or API registration ID
      string provider;        // e.g. "SolarEdge", "Enphase"
      uint256 capacityWatts;  // System capacity size in Watts
      uint256 registeredAt;   // Registration timestamp
  }
  ```
- **Rewards Gate**: Ownership of a registered setup NFT is verified prior to reward claims.

## 🟨 Layer 3: Oracle-Gated Reward Claims
- **Telemetry Verification**: Standardizes off-chain telemetry verification via cryptographic ECDSA signature checks:
  ```solidity
  bytes32 messageHash = keccak256(abi.encodePacked(tokenId, cumulativeKWh, deadline, address(this)));
  ```
- **Prevention of Double-Spending**: Records previously claimed kWh on-chain per token ID, rewarding only the positive delta of cumulative production.
- **Dynamic Rate**: Multiplies telemetry delta by a customizable rate (e.g. 10 UNYE per kWh).

## 🟧 Layer 4: P2P Local Grid Trading Escrow
- **Escrow flow**: 
  1. Seller (holding a registered setup NFT) creates an offer detailing energy volume (kWh) and token price.
  2. Buyer purchases the offer by locking the token price in escrow.
  3. Buyer confirms the physical delivery of kWh to release tokens to the seller.
- **Dispute Resolution**: Includes an arbitrator hook (`resolveDispute`) to resolve trading disputes by either executing the payout or refunding the buyer.

## 🟪 Layer 5: DAO Governance
- **Proposals & Voting**: 1,000,000 UNYE tokens are required to submit a proposal.
- **Timelock Control**: All successful proposals must wait a minimum delay (default: 2 days) before execution.
- **Governance Subjects**: Adjusting transfer fees, modifying reward rates, updating authorized oracle verifiers, or upgrading contract proxies.

---

## 🛠️ Developer Setup & Compilation

Ensure you have [Foundry](https://book.getfoundry.sh/) installed.

### 1. Install Dependencies
```bash
npm install
```

### 2. Compile Contracts
Compile using the via-IR pipeline configured in `foundry.toml`:
```bash
forge build
```

### 3. Run Automated Tests
Execute the full unit test suite with gas profiling enabled:
```bash
forge test -vvv
```

---

## 🚀 Deployment Instructions

To execute a full deployment and transition ownership to the DAO timelock in a single step:

1. Configure environment variables:
   ```bash
   $env:PRIVATE_KEY="<YOUR_DEPLOYER_PRIVATE_KEY>"
   $env:TREASURY_ADDRESS="<TREASURY_MULTISIG_ADDRESS>"
   $env:VERIFIER_ADDRESS="<ORACLE_VERIFIER_PUBLIC_KEY>"
   $env:ARBITRATOR_ADDRESS="<DISPUTE_ARBITRATOR_ADDRESS>"
   ```

2. Run the deployment script:
   ```bash
   forge script script/Deploy.s.sol --rpc-url <YOUR_RPC_URL> --broadcast --verify
   ```

---
*Created professionally for **FTHTrading**. Copyright © 2026. All rights reserved.*
