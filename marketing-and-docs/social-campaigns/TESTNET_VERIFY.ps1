# Unykorn Energy — BNB Testnet Verification Script
# Usage: .\TESTNET_VERIFY.ps1 -TokenAddress 0x... -NftAddress 0x... -DistributorAddress 0x...

param(
    [Parameter(Mandatory = $true)][string]$TokenAddress,
    [Parameter(Mandatory = $true)][string]$NftAddress,
    [Parameter(Mandatory = $true)][string]$DistributorAddress,
    [string]$RpcUrl = "https://data-seed-prebsc-1-s1.binance.org:8545"
)

Write-Host "`n=== UNYKORN ENERGY — BNB TESTNET VERIFICATION ===" -ForegroundColor Cyan

$checks = @(
    @{ Label = "Token Name";    Cmd = "cast call $TokenAddress `"name()(string)`" --rpc-url $RpcUrl" },
    @{ Label = "Token Symbol";  Cmd = "cast call $TokenAddress `"symbol()(string)`" --rpc-url $RpcUrl" },
    @{ Label = "Total Supply";  Cmd = "cast call $TokenAddress `"totalSupply()(uint256)`" --rpc-url $RpcUrl" },
    @{ Label = "NFT Name";       Cmd = "cast call $NftAddress `"name()(string)`" --rpc-url $RpcUrl" },
    @{ Label = "Distributor Sub"; Cmd = "cast call $DistributorAddress `"subscriptionId()(uint64)`" --rpc-url $RpcUrl" }
)

foreach ($check in $checks) {
    Write-Host "`n[$($check.Label)]" -ForegroundColor Yellow
    Invoke-Expression $check.Cmd
}

Write-Host "`n=== VERIFICATION COMPLETE ===" -ForegroundColor Green