// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract SolarSetupNFT is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    struct InverterMetadata {
        string inverterId;
        string provider;
        uint256 capacityWatts;
        uint256 registeredAt;
    }

    uint256 private _nextTokenId;
    mapping(uint256 => InverterMetadata) private _inverters;
    mapping(string => bool) public isRegistered;

    event SolarSetupRegistered(uint256 indexed tokenId, address indexed owner, string inverterId, string provider, uint256 capacityWatts);

    constructor() { _disableInitializers(); }

    function initialize(string memory name, string memory symbol, address initialOwner) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(initialOwner);
        _nextTokenId = 1;
    }

    function registerSetup(address to, string calldata inverterId, string calldata provider, uint256 capacityWatts) external onlyOwner returns (uint256) {
        require(!isRegistered[inverterId], "Inverter already registered");
        require(bytes(inverterId).length > 0, "Empty inverter ID");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _inverters[tokenId] = InverterMetadata({inverterId: inverterId, provider: provider, capacityWatts: capacityWatts, registeredAt: block.timestamp});
        isRegistered[inverterId] = true;
        emit SolarSetupRegistered(tokenId, to, inverterId, provider, capacityWatts);
        return tokenId;
    }

    function getInverterMetadata(uint256 tokenId) external view returns (InverterMetadata memory) {
        _requireOwned(tokenId);
        return _inverters[tokenId];
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
