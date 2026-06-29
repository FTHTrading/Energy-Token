// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ERC20VotesUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import {NoncesUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract UnykornEnergyToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public taxBps;
    address public treasury;
    mapping(address => bool) public isTaxExempt;
    address public distributor;
    uint256 public constant MAX_SUPPLY = 250_000_000 * 1e18;

    event TaxBpsUpdated(uint256 oldTax, uint256 newTax);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event TaxExemptionUpdated(address indexed target, bool isExempt);
    event DistributorUpdated(address indexed oldDistributor, address indexed newDistributor);

    constructor() { _disableInitializers(); }

    function initialize(string memory name, string memory symbol, address initialOwner, address _treasury) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Burnable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init(name);
        __ERC20Votes_init();
        require(_treasury != address(0), "Invalid treasury");
        treasury = _treasury;
        taxBps = 0;
        _mint(_treasury, 50_000_000 * 10 ** decimals());
        isTaxExempt[initialOwner] = true;
        isTaxExempt[_treasury] = true;
        isTaxExempt[address(this)] = true;
    }

    function setTaxBps(uint256 _taxBps) external onlyOwner {
        require(_taxBps <= 200, "Tax exceeds 2% limit");
        emit TaxBpsUpdated(taxBps, _taxBps);
        taxBps = _taxBps;
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid treasury address");
        emit TreasuryUpdated(treasury, _treasury);
        treasury = _treasury;
    }

    function setTaxExemption(address target, bool exempt) external onlyOwner {
        isTaxExempt[target] = exempt;
        emit TaxExemptionUpdated(target, exempt);
    }

    function setDistributor(address _distributor) external onlyOwner {
        emit DistributorUpdated(distributor, _distributor);
        distributor = _distributor;
        isTaxExempt[_distributor] = true;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner() || msg.sender == distributor, "Not authorized to mint");
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds 250M max supply");
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20Upgradeable, ERC20VotesUpgradeable) {
        if (from == address(0) || to == address(0) || taxBps == 0 || isTaxExempt[from] || isTaxExempt[to]) {
            super._update(from, to, value);
        } else {
            uint256 taxAmount = (value * taxBps) / 10000;
            uint256 netAmount = value - taxAmount;
            if (taxAmount > 0) super._update(from, treasury, taxAmount);
            super._update(from, to, netAmount);
        }
    }

    function nonces(address owner) public view override(ERC20PermitUpgradeable, NoncesUpgradeable) returns (uint256) {
        return super.nonces(owner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
