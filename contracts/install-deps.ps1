# Install Foundry + npm deps for clone builds when forge-std is incomplete
# Run from contracts/ directory

$ErrorActionPreference = "Stop"

if (-not (Test-Path "lib/forge-std/src/Vm.sol")) {
    Write-Host "Installing forge-std..."
    forge install foundry-rs/forge-std --no-commit
}

if (-not (Test-Path "node_modules/@openzeppelin/contracts")) {
    Write-Host "Installing npm dependencies..."
    npm install
}

Write-Host "Running forge test..."
forge test -vvv
