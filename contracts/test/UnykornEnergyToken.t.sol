// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UnykornEnergyToken} from "../src/UnykornEnergyToken.sol";
import {SolarSetupNFT} from "../src/SolarSetupNFT.sol";
import {SolarRewardsDistributor} from "../src/SolarRewardsDistributor.sol";
import {P2PEnergyEscrow} from "../src/P2PEnergyEscrow.sol";

contract UnykornEnergyTokenTest is Test {
    UnykornEnergyToken public token;
    SolarSetupNFT public nft;
    SolarRewardsDistributor public distributor;
    P2PEnergyEscrow public escrow;

    address public owner = address(0x99);
    address public treasury = address(0x100);
    address public chainlinkRouter = 0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C;
    address public arbitrator = address(0x200);

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        // 1. Deploy Token
        UnykornEnergyToken tokenImpl = new UnykornEnergyToken();
        bytes memory tokenInit = abi.encodeWithSelector(
            UnykornEnergyToken.initialize.selector, "Unykorn Energy Token", "UNYE", owner, treasury
        );
        token = UnykornEnergyToken(address(new ERC1967Proxy(address(tokenImpl), tokenInit)));

        // 2. Deploy NFT
        SolarSetupNFT nftImpl = new SolarSetupNFT();
        bytes memory nftInit =
            abi.encodeWithSelector(SolarSetupNFT.initialize.selector, "Unykorn Solar Setup NFT", "UNY-SOLAR", owner);
        nft = SolarSetupNFT(address(new ERC1967Proxy(address(nftImpl), nftInit)));

        // 3. Deploy Distributor (Chainlink Functions)
        SolarRewardsDistributor distributorImpl = new SolarRewardsDistributor(chainlinkRouter);
        bytes memory distInit = abi.encodeWithSelector(
            SolarRewardsDistributor.initialize.selector, address(token), address(nft), uint64(1), owner
        );
        distributor = SolarRewardsDistributor(address(new ERC1967Proxy(address(distributorImpl), distInit)));

        // 4. Deploy Escrow
        P2PEnergyEscrow escrowImpl = new P2PEnergyEscrow();
        bytes memory escrowInit = abi.encodeWithSelector(
            P2PEnergyEscrow.initialize.selector, address(token), address(nft), arbitrator, owner
        );
        escrow = P2PEnergyEscrow(address(new ERC1967Proxy(address(escrowImpl), escrowInit)));

        // Setup transfer tax exemptions and dynamic mint authority
        vm.startPrank(owner);
        token.setDistributor(address(distributor));
        token.setTaxExemption(address(escrow), true);
        vm.stopPrank();
    }

    // ==========================================
    // ERC20 Token Tests
    // ==========================================

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), 50_000_000 * 10 ** 18);
        assertEq(token.balanceOf(treasury), 50_000_000 * 10 ** 18);
    }

    function test_TransferTax() public {
        vm.prank(owner);
        token.setTaxBps(100); // 1% tax

        // Give user1 some tokens
        vm.prank(treasury);
        token.transfer(user1, 1000 * 10 ** 18);

        // Exempt address check (treasury is exempt)
        assertEq(token.balanceOf(user1), 1000 * 10 ** 18);

        // Perform tax transfer: user1 to user2 (not exempt)
        uint256 initTreasuryBal = token.balanceOf(treasury);
        vm.prank(user1);
        token.transfer(user2, 100 * 10 ** 18);

        // 1% of 100 is 1 token
        assertEq(token.balanceOf(user2), 99 * 10 ** 18);
        assertEq(token.balanceOf(treasury), initTreasuryBal + 1 * 10 ** 18);
    }

    function test_TaxExemption() public {
        vm.prank(owner);
        token.setTaxBps(100); // 1% tax
        vm.prank(owner);
        token.setTaxExemption(user1, true); // Whitelist user1

        vm.prank(treasury);
        token.transfer(user1, 1000 * 10 ** 18);

        vm.prank(user1);
        token.transfer(user2, 100 * 10 ** 18); // user1 is exempt, so no tax should be deducted

        assertEq(token.balanceOf(user2), 100 * 10 ** 18);
    }

    // ==========================================
    // DePIN Solar Setup NFT Tests
    // ==========================================

    function test_RegisterSetup() public {
        vm.prank(owner);
        uint256 tokenId = nft.registerSetup(user1, "SE123456", "SolarEdge", 5000);

        assertEq(tokenId, 1);
        assertEq(nft.ownerOf(tokenId), user1);

        SolarSetupNFT.InverterMetadata memory meta = nft.getInverterMetadata(tokenId);
        assertEq(meta.inverterId, "SE123456");
        assertEq(meta.provider, "SolarEdge");
        assertEq(meta.capacityWatts, 5000);
    }

    function test_FailDuplicateRegistration() public {
        vm.startPrank(owner);
        nft.registerSetup(user1, "SE123456", "SolarEdge", 5000);
        vm.expectRevert("Inverter already registered");
        nft.registerSetup(user2, "SE123456", "Enphase", 6000);
        vm.stopPrank();
    }

    // ==========================================
    // Solar Rewards Distributor Tests
    // ==========================================

    function test_DistributorConfig() public view {
        assertEq(distributor.subscriptionId(), 1);
        assertEq(address(distributor.rewardToken()), address(token));
        assertEq(address(distributor.setupNFT()), address(nft));
    }

    function test_FailRequestKWhVerificationNotOwner() public {
        vm.prank(owner);
        uint256 tokenId = nft.registerSetup(user1, "SE-DIST", "SolarEdge", 8000);

        vm.prank(user2);
        vm.expectRevert("Caller does not own setup NFT");
        distributor.requestKWhVerification(tokenId, "12345");
    }

    // ==========================================
    // P2P Energy Escrow Tests
    // ==========================================

    function test_P2PTradeFlow() public {
        // 1. Setup seller (user1) with solar setup NFT
        vm.prank(owner);
        uint256 tokenId = nft.registerSetup(user1, "SE-P2P", "SolarEdge", 10000);

        // 2. Setup buyer (user2) with tokens
        vm.prank(treasury);
        token.transfer(user2, 500 * 10 ** 18);

        // 3. Seller lists energy: 50 kWh for 100 tokens
        vm.prank(user1);
        uint256 offerId = escrow.createOffer(tokenId, 50, 100 * 10 ** 18);

        // Verify offer details
        (
            address listedSeller,
            address listedBuyer,
            uint256 lTokenId,
            uint256 lKWh,
            uint256 lPrice,
            bool active,
            bool filled,
            bool completed
        ) = escrow.offers(offerId);
        assertEq(listedSeller, user1);
        assertEq(listedBuyer, address(0));
        assertEq(lTokenId, tokenId);
        assertEq(lKWh, 50);
        assertEq(lPrice, 100 * 10 ** 18);
        assertTrue(active);
        assertFalse(filled);
        assertFalse(completed);

        // 4. Buyer approves and fills offer
        vm.startPrank(user2);
        token.approve(address(escrow), 100 * 10 ** 18);
        escrow.fillOffer(offerId);
        vm.stopPrank();

        // Verify tokens are locked in escrow
        assertEq(token.balanceOf(address(escrow)), 100 * 10 ** 18);
        assertEq(token.balanceOf(user2), 400 * 10 ** 18);

        (, listedBuyer,,,, active, filled,) = escrow.offers(offerId);
        assertEq(listedBuyer, user2);
        assertFalse(active);
        assertTrue(filled);

        // 5. Buyer confirms delivery (releases funds to seller)
        uint256 initSellerBalance = token.balanceOf(user1);
        vm.prank(user2);
        escrow.confirmDelivery(offerId);

        // Verify trade is completed and funds released
        assertEq(token.balanceOf(address(escrow)), 0);
        assertEq(token.balanceOf(user1), initSellerBalance + 100 * 10 ** 18);

        (,,,,,,, completed) = escrow.offers(offerId);
        assertTrue(completed);
    }

    function test_P2PDisputeRefund() public {
        vm.prank(owner);
        uint256 tokenId = nft.registerSetup(user1, "SE-DISP", "SolarEdge", 10000);

        vm.prank(treasury);
        token.transfer(user2, 500 * 10 ** 18);

        vm.prank(user1);
        uint256 offerId = escrow.createOffer(tokenId, 50, 100 * 10 ** 18);

        vm.startPrank(user2);
        token.approve(address(escrow), 100 * 10 ** 18);
        escrow.fillOffer(offerId);
        vm.stopPrank();

        // Arbitrator refunds buyer due to delivery failure
        vm.prank(arbitrator);
        escrow.resolveDispute(offerId, false); // releaseToSeller = false (refund)

        assertEq(token.balanceOf(user2), 500 * 10 ** 18);
        assertEq(token.balanceOf(address(escrow)), 0);

        (,,,,,,, bool completed) = escrow.offers(offerId);
        assertTrue(completed);
    }
}
