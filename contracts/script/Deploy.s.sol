// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UnykornEnergyToken} from "../src/UnykornEnergyToken.sol";
import {SolarSetupNFT} from "../src/SolarSetupNFT.sol";
import {SolarRewardsDistributor} from "../src/SolarRewardsDistributor.sol";
import {P2PEnergyEscrow} from "../src/P2PEnergyEscrow.sol";
import {UnykornTimelock} from "../src/UnykornTimelock.sol";
import {UnykornGovernor} from "../src/UnykornGovernor.sol";

/**
 * @title DeployScript
 * @dev Deployment script for Unykorn Energy ecosystem.
 * Deploys token, NFT, distributor, escrow, and governance with proper role transfers.
 */
contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey =
            vm.envOr("PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80));
        address deployer = vm.addr(deployerPrivateKey);

        // Configuration
        address treasury = vm.envOr("TREASURY_ADDRESS", deployer);
        address verifier = vm.envOr("VERIFIER_ADDRESS", deployer);
        address arbitrator = vm.envOr("ARBITRATOR_ADDRESS", deployer);

        console.log("Deployer address:", deployer);
        console.log("Treasury address:", treasury);
        console.log("Verifier address:", verifier);
        console.log("Arbitrator address:", arbitrator);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy UnykornEnergyToken (UUPS Proxy)
        UnykornEnergyToken tokenImpl = new UnykornEnergyToken();
        bytes memory tokenInit = abi.encodeWithSelector(
            UnykornEnergyToken.initialize.selector, "Unykorn Energy Token", "UNYE", deployer, treasury
        );
        ERC1967Proxy tokenProxy = new ERC1967Proxy(address(tokenImpl), tokenInit);
        UnykornEnergyToken token = UnykornEnergyToken(address(tokenProxy));
        console.log("UnykornEnergyToken Proxy deployed at:", address(token));

        // 2. Deploy SolarSetupNFT (UUPS Proxy)
        SolarSetupNFT nftImpl = new SolarSetupNFT();
        bytes memory nftInit =
            abi.encodeWithSelector(SolarSetupNFT.initialize.selector, "Unykorn Solar Setup NFT", "UNY-SOLAR", deployer);
        ERC1967Proxy nftProxy = new ERC1967Proxy(address(nftImpl), nftInit);
        SolarSetupNFT nft = SolarSetupNFT(address(nftProxy));
        console.log("SolarSetupNFT Proxy deployed at:", address(nft));

        // 3. Deploy SolarRewardsDistributor (UUPS Proxy)
        address chainlinkRouter = 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C; // BNB Testnet Functions Router
        uint64 subscriptionId = uint64(vm.envOr("CHAINLINK_SUB_ID", uint256(1))); // Default sub ID 1 for testing
        
        SolarRewardsDistributor distributorImpl = new SolarRewardsDistributor(chainlinkRouter);
        bytes memory distInit = abi.encodeWithSelector(
            SolarRewardsDistributor.initialize.selector, address(token), address(nft), subscriptionId, deployer
        );
        ERC1967Proxy distProxy = new ERC1967Proxy(address(distributorImpl), distInit);
        SolarRewardsDistributor distributor = SolarRewardsDistributor(address(distProxy));
        console.log("SolarRewardsDistributor Proxy deployed at:", address(distributor));

        // 4. Deploy P2PEnergyEscrow (UUPS Proxy)
        P2PEnergyEscrow escrowImpl = new P2PEnergyEscrow();
        bytes memory escrowInit = abi.encodeWithSelector(
            P2PEnergyEscrow.initialize.selector, address(token), address(nft), arbitrator, deployer
        );
        ERC1967Proxy escrowProxy = new ERC1967Proxy(address(escrowImpl), escrowInit);
        P2PEnergyEscrow escrow = P2PEnergyEscrow(address(escrowProxy));
        console.log("P2PEnergyEscrow Proxy deployed at:", address(escrow));

        // 5. Deploy Governance Timelock
        // Delay: 2 days (172800 seconds)
        uint256 minDelay = 172800;
        address[] memory proposers = new address[](0); // Set later
        address[] memory executors = new address[](1);
        executors[0] = address(0); // Anyone can execute once timelocked

        UnykornTimelock timelock = new UnykornTimelock(
            minDelay,
            proposers,
            executors,
            deployer // Temporarily admin, will renounce
        );
        console.log("UnykornTimelock deployed at:", address(timelock));

        // 6. Deploy Governor
        // Voting delay: 1 block, Period: 7200 blocks (~1 day), Threshold: 1,000,000 UNYE, Quorum: 4%
        UnykornGovernor governor = new UnykornGovernor(token, timelock, 1, 7200, 1_000_000 * 10 ** 18, 4);
        console.log("UnykornGovernor deployed at:", address(governor));

        // 7. Setup Governance Roles
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        // Grant proposer to Governor
        timelock.grantRole(proposerRole, address(governor));
        // Grant executor to Governor
        timelock.grantRole(executorRole, address(governor));
        // Revoke admin from deployer
        timelock.revokeRole(adminRole, deployer);

        // 8. Whitelist system contracts for tax exemption and set dynamic minter
        token.setDistributor(address(distributor));
        token.setTaxExemption(address(escrow), true);

        // 9. Transfer Ownership of target contracts to Timelock (pure DAO control)
        token.transferOwnership(address(timelock));
        nft.transferOwnership(address(timelock));
        distributor.transferOwnership(address(timelock));
        escrow.transferOwnership(address(timelock));

        console.log("Deployment and DAO setup completed successfully!");

        vm.stopBroadcast();
    }
}
