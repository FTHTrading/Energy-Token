// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SolarSetupNFT} from "./SolarSetupNFT.sol";

/**
 * @title P2PEnergyEscrow
 * @dev Escrow contract to facilitate P2P local energy (kWh) trading using Unykorn Energy Tokens.
 */
contract P2PEnergyEscrow is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    struct Offer {
        address seller;
        address buyer;
        uint256 tokenId;
        uint256 kWh;
        uint256 tokenPrice;
        bool active;
        bool filled;
        bool completed;
    }

    IERC20 public paymentToken;
    SolarSetupNFT public setupNFT;
    uint256 public nextOfferId;
    address public arbitrator;
    mapping(uint256 => Offer) public offers;

    event OfferCreated(uint256 indexed offerId, address indexed seller, uint256 tokenId, uint256 kWh, uint256 tokenPrice);
    event OfferFilled(uint256 indexed offerId, address indexed buyer);
    event OfferCompleted(uint256 indexed offerId);
    event OfferCancelled(uint256 indexed offerId);
    event OfferRefunded(uint256 indexed offerId);
    event ArbitratorUpdated(address indexed oldArbitrator, address indexed newArbitrator);

    constructor() { _disableInitializers(); }

    function initialize(address _paymentToken, address _setupNFT, address _arbitrator, address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        require(_paymentToken != address(0), "Invalid token");
        require(_setupNFT != address(0), "Invalid NFT");
        require(_arbitrator != address(0), "Invalid arbitrator");
        paymentToken = IERC20(_paymentToken);
        setupNFT = SolarSetupNFT(_setupNFT);
        arbitrator = _arbitrator;
        nextOfferId = 1;
    }

    function createOffer(uint256 tokenId, uint256 kWh, uint256 tokenPrice) external returns (uint256) {
        require(setupNFT.ownerOf(tokenId) == msg.sender, "Must own setup NFT to sell energy");
        require(kWh > 0, "kWh must be greater than 0");
        require(tokenPrice > 0, "Price must be greater than 0");
        uint256 offerId = nextOfferId++;
        offers[offerId] = Offer({seller: msg.sender, buyer: address(0), tokenId: tokenId, kWh: kWh, tokenPrice: tokenPrice, active: true, filled: false, completed: false});
        emit OfferCreated(offerId, msg.sender, tokenId, kWh, tokenPrice);
        return offerId;
    }

    function fillOffer(uint256 offerId) external {
        Offer storage offer = offers[offerId];
        require(offer.active, "Offer not active");
        require(!offer.filled, "Offer already filled");
        require(offer.seller != msg.sender, "Cannot buy own offer");
        offer.buyer = msg.sender;
        offer.filled = true;
        offer.active = false;
        require(paymentToken.transferFrom(msg.sender, address(this), offer.tokenPrice), "Escrow token lock failed");
        emit OfferFilled(offerId, msg.sender);
    }

    function confirmDelivery(uint256 offerId) external {
        Offer storage offer = offers[offerId];
        require(offer.filled, "Offer not filled");
        require(!offer.completed, "Offer already completed");
        require(offer.buyer == msg.sender, "Only buyer can confirm delivery");
        offer.completed = true;
        require(paymentToken.transfer(offer.seller, offer.tokenPrice), "Token payout to seller failed");
        emit OfferCompleted(offerId);
    }

    function cancelOffer(uint256 offerId) external {
        Offer storage offer = offers[offerId];
        require(offer.active, "Offer not active");
        require(!offer.filled, "Cannot cancel filled offer");
        require(offer.seller == msg.sender, "Only seller can cancel");
        offer.active = false;
        emit OfferCancelled(offerId);
    }

    function resolveDispute(uint256 offerId, bool releaseToSeller) external {
        require(msg.sender == arbitrator || msg.sender == owner(), "Unauthorized arbitrator");
        Offer storage offer = offers[offerId];
        require(offer.filled, "Offer not filled");
        require(!offer.completed, "Offer already completed");
        offer.completed = true;
        if (releaseToSeller) {
            require(paymentToken.transfer(offer.seller, offer.tokenPrice), "Token payout failed");
            emit OfferCompleted(offerId);
        } else {
            require(paymentToken.transfer(offer.buyer, offer.tokenPrice), "Refund transfer failed");
            emit OfferRefunded(offerId);
        }
    }

    function setArbitrator(address _arbitrator) external onlyOwner {
        require(_arbitrator != address(0), "Invalid arbitrator");
        emit ArbitratorUpdated(arbitrator, _arbitrator);
        arbitrator = _arbitrator;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
