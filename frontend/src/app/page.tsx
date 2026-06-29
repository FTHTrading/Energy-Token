const TOC = [
  { id: "overview", label: "Overview" },
  { id: "architecture", label: "Architecture" },
  { id: "tokenomics", label: "Tokenomics" },
  { id: "layers", label: "System Layers" },
  { id: "contracts", label: "Contracts" },
  { id: "quickstart", label: "Quick Start" },
  { id: "deploy", label: "BNB Testnet" },
  { id: "links", label: "Resources" },
] as const;

const LAYERS = [
  {
    color: "border-emerald-500/40 bg-emerald-500/10",
    badge: "UNYE",
    badgeColor: "bg-emerald-500/20 text-emerald-300",
    title: "Core Token",
    desc: "250M cap ERC20 with UUPS upgrades, transfer tax routing, and vote delegation.",
  },
  {
    color: "border-blue-500/40 bg-blue-500/10",
    badge: "NFT",
    badgeColor: "bg-blue-500/20 text-blue-300",
    title: "DePIN Solar Registry",
    desc: "UNY-SOLAR NFTs map inverters (SolarEdge, Enphase) to on-chain hardware proofs.",
  },
  {
    color: "border-amber-500/40 bg-amber-500/10",
    badge: "Oracle",
    badgeColor: "bg-amber-500/20 text-amber-300",
    title: "Chainlink Rewards",
    desc: "Functions router verifies kWh telemetry before dynamic UNYE minting.",
  },
  {
    color: "border-orange-500/40 bg-orange-500/10",
    badge: "P2P",
    badgeColor: "bg-orange-500/20 text-orange-300",
    title: "Energy Escrow",
    desc: "Local kWh listings, buyer escrow, delivery confirmation, and arbitration.",
  },
  {
    color: "border-purple-500/40 bg-purple-500/10",
    badge: "DAO",
    badgeColor: "bg-purple-500/20 text-purple-300",
    title: "Governance",
    desc: "Governor + 48h timelock. Upgrades, tax rates, and oracle policy via proposals.",
  },
] as const;

const CONTRACTS = [
  ["UnykornEnergyToken.sol", "ERC20 UNYE — tax, mint cap, distributor authority"],
  ["SolarSetupNFT.sol", "Hardware registry NFT (UNY-SOLAR)"],
  ["SolarRewardsDistributor.sol", "Chainlink kWh verification + rewards"],
  ["P2PEnergyEscrow.sol", "P2P energy marketplace escrow"],
  ["UnykornGovernor.sol", "OpenZeppelin Governor proposals & voting"],
  ["UnykornTimelock.sol", "48-hour execution delay for DAO actions"],
] as const;

function Badge({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <span
      className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-medium tracking-wide ${className ?? ""}`}
    >
      {children}
    </span>
  );
}

export default function Home() {
  return (
    <div className="min-h-screen gradient-hero">
      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-[#1e2740]/80 bg-[#06080f]/80 backdrop-blur-md">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-cyan-500 text-lg font-bold text-[#06080f]">
              U
            </div>
            <div>
              <p className="text-sm font-semibold tracking-tight">Unykorn Energy</p>
              <p className="text-xs text-[#9aa3b8]">FTHTrading · Energy-Token</p>
            </div>
          </div>
          <div className="hidden gap-2 sm:flex">
            <Badge className="bg-emerald-500/15 text-emerald-300 ring-1 ring-emerald-500/30">
              Solidity 0.8.24
            </Badge>
            <Badge className="bg-amber-500/15 text-amber-300 ring-1 ring-amber-500/30">
              BNB Testnet
            </Badge>
            <Badge className="bg-purple-500/15 text-purple-300 ring-1 ring-purple-500/30">
              DAO Timelock
            </Badge>
          </div>
        </div>
      </header>

      <div className="mx-auto grid max-w-7xl gap-10 px-6 py-12 lg:grid-cols-[220px_1fr]">
        {/* Table of Contents */}
        <aside className="hidden lg:block">
          <nav className="card-surface sticky top-24 rounded-2xl p-5">
            <p className="mb-4 text-xs font-semibold uppercase tracking-widest text-[#9aa3b8]">
              Contents
            </p>
            <ul className="space-y-2 text-sm">
              {TOC.map((item) => (
                <li key={item.id}>
                  <a href={`#${item.id}`} className="toc-link block py-1">
                    {item.label}
                  </a>
                </li>
              ))}
            </ul>
          </nav>
        </aside>

        {/* Main content */}
        <main className="min-w-0 space-y-16">
          {/* Hero */}
          <section id="overview" className="scroll-mt-24">
            <p className="mb-3 text-sm font-medium text-emerald-400">Verifiable DePIN Solar Ecosystem</p>
            <h1 className="max-w-3xl text-4xl font-bold leading-tight tracking-tight sm:text-5xl">
              Real solar production.
              <span className="block bg-gradient-to-r from-emerald-300 via-amber-200 to-cyan-300 bg-clip-text text-transparent">
                On-chain rewards.
              </span>
            </h1>
            <p className="mt-6 max-w-2xl text-lg leading-relaxed text-[#9aa3b8]">
              Unykorn Energy Token (UNYE) mints only when Chainlink verifies kWh from registered
              inverters. Trade surplus energy P2P, govern upgrades via DAO, and deploy on BNB
              Smart Chain testnet today.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <a
                href="https://github.com/FTHTrading/Energy-Token"
                target="_blank"
                rel="noopener noreferrer"
                className="rounded-xl bg-emerald-500 px-5 py-2.5 text-sm font-semibold text-[#06080f] transition hover:bg-emerald-400"
              >
                View on GitHub
              </a>
              <a
                href="#quickstart"
                className="rounded-xl border border-[#1e2740] px-5 py-2.5 text-sm font-semibold text-[#f4f6fb] transition hover:border-emerald-500/50 hover:bg-emerald-500/5"
              >
                Quick Start
              </a>
            </div>
          </section>

          {/* Architecture */}
          <section id="architecture" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">Architecture</h2>
            <div className="card-surface overflow-hidden rounded-2xl">
              <div className="grid gap-px bg-[#1e2740] sm:grid-cols-5">
                {["Inverter API", "Chainlink", "Distributor", "UNYE + NFT", "P2P Escrow"].map(
                  (step, i) => (
                    <div key={step} className="bg-[#0f1424] p-4 text-center">
                      <p className="text-xs text-[#9aa3b8]">Step {i + 1}</p>
                      <p className="mt-1 text-sm font-medium">{step}</p>
                    </div>
                  ),
                )}
              </div>
              <p className="border-t border-[#1e2740] p-4 text-sm text-[#9aa3b8]">
                Telemetry flows from SolarEdge/Enphase → Chainlink Functions → verified mint →
                treasury & holder balances → optional P2P escrow settlement.
              </p>
            </div>
          </section>

          {/* Tokenomics */}
          <section id="tokenomics" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">Tokenomics</h2>
            <div className="overflow-x-auto rounded-2xl border border-[#1e2740]">
              <table className="w-full min-w-[480px] text-left text-sm">
                <thead className="bg-[#0f1424] text-xs uppercase tracking-wider text-[#9aa3b8]">
                  <tr>
                    <th className="px-5 py-3">Parameter</th>
                    <th className="px-5 py-3">Value</th>
                    <th className="px-5 py-3">Notes</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#1e2740]">
                  {[
                    ["Symbol", "UNYE", "Unykorn Energy Token"],
                    ["Max Supply", "250,000,000", "Hard cap — no inflation beyond verified mint"],
                    ["Genesis", "50,000,000 (20%)", "Treasury liquidity & marketing"],
                    ["Reward Rate", "1 UNYE / 5 kWh", "Chainlink-verified production only"],
                    ["Transfer Tax", "0–2% (DAO)", "Escrow & distributor tax-exempt"],
                    ["Governance", "1M UNYE threshold", "48h timelock on execution"],
                  ].map(([param, value, notes]) => (
                    <tr key={param} className="bg-[#0a0e1a]/60 hover:bg-[#0f1424]/80">
                      <td className="px-5 py-3 font-medium text-emerald-300">{param}</td>
                      <td className="px-5 py-3 font-mono text-amber-200">{value}</td>
                      <td className="px-5 py-3 text-[#9aa3b8]">{notes}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          {/* Layers */}
          <section id="layers" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">System Layers</h2>
            <div className="grid gap-4 sm:grid-cols-2">
              {LAYERS.map((layer) => (
                <article
                  key={layer.title}
                  className={`card-surface rounded-2xl border p-5 ${layer.color}`}
                >
                  <Badge className={layer.badgeColor}>{layer.badge}</Badge>
                  <h3 className="mt-3 text-lg font-semibold">{layer.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-[#9aa3b8]">{layer.desc}</p>
                </article>
              ))}
            </div>
          </section>

          {/* Contracts */}
          <section id="contracts" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">Smart Contracts</h2>
            <div className="card-surface overflow-hidden rounded-2xl">
              <table className="w-full text-left text-sm">
                <thead className="border-b border-[#1e2740] bg-[#0f1424] text-xs uppercase text-[#9aa3b8]">
                  <tr>
                    <th className="px-5 py-3">File</th>
                    <th className="px-5 py-3">Role</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#1e2740]">
                  {CONTRACTS.map(([file, role]) => (
                    <tr key={file}>
                      <td className="px-5 py-3 font-mono text-cyan-300">{file}</td>
                      <td className="px-5 py-3 text-[#9aa3b8]">{role}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </section>

          {/* Quick Start */}
          <section id="quickstart" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">Quick Start</h2>
            <pre className="card-surface overflow-x-auto rounded-2xl p-5 text-sm leading-relaxed text-emerald-100/90">
              <code>{`git clone https://github.com/FTHTrading/Energy-Token.git
cd Energy-Token/contracts
forge install foundry-rs/forge-std --no-commit
npm install
forge build && forge test -vvv`}</code>
            </pre>
          </section>

          {/* Deploy */}
          <section id="deploy" className="scroll-mt-24">
            <h2 className="mb-6 text-2xl font-bold">BNB Testnet Deploy</h2>
            <div className="card-surface rounded-2xl p-5">
              <p className="text-sm text-[#9aa3b8]">
                Fund deployer with ≥0.01 tBNB via{" "}
                <a
                  href="https://testnet.bnbchain.org/faucet-smart"
                  className="text-amber-300 underline-offset-2 hover:underline"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  BNB faucet
                </a>
                , then broadcast <code className="text-cyan-300">Deploy.s.sol</code>. Estimated
                gas: ~0.002 BNB.
              </p>
              <pre className="mt-4 overflow-x-auto rounded-xl bg-[#06080f] p-4 text-xs text-[#9aa3b8]">
                <code>{`forge script script/Deploy.s.sol \\
  --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 \\
  --broadcast --verify`}</code>
              </pre>
            </div>
          </section>

          {/* Links */}
          <section id="links" className="scroll-mt-24 pb-16">
            <h2 className="mb-6 text-2xl font-bold">Resources</h2>
            <div className="flex flex-wrap gap-3">
              {[
                ["GitHub Repo", "https://github.com/FTHTrading/Energy-Token"],
                ["Whitepaper", "/marketing-and-docs/WHITEPAPER.md"],
                ["Deploy Guide", "/marketing-and-docs/DEPLOYMENT_BNB_TESTNET.md"],
              ].map(([label, href]) => (
                <a
                  key={label}
                  href={href.startsWith("http") ? href : `https://github.com/FTHTrading/Energy-Token/blob/main${href}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rounded-lg border border-[#1e2740] px-4 py-2 text-sm text-[#9aa3b8] transition hover:border-emerald-500/40 hover:text-emerald-300"
                >
                  {label} →
                </a>
              ))}
            </div>
            <p className="mt-10 text-xs text-[#6b7280]">FTHTrading · Copyright 2026</p>
          </section>
        </main>
      </div>
    </div>
  );
}
