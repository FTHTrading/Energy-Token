// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {SolarSetupNFT} from "./SolarSetupNFT.sol";
import "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

interface IUnykornEnergyToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract SolarRewardsDistributor is Initializable, OwnableUpgradeable, UUPSUpgradeable, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    IUnykornEnergyToken public rewardToken;
    SolarSetupNFT public setupNFT;
    uint64 public subscriptionId;
    bytes32 public lastRequestId;
    bytes public encryptedSecrets;

    string public source =
        "const solarID = args[0];"
        "const response = await Functions.makeHttpRequest({"
        "  url: `https://monitoringapi.solaredge.com/site/${solarID}/overview`,"
        "  headers: { 'Authorization': secrets.apiKey }"
        "});"
        "if (response.error) { throw Error('Functions HTTP Request Error'); }"
        "return Functions.encodeUint256(response.data.overview.lastDayEnergy / 1000);";

    mapping(bytes32 => uint256) public requestToTokenId;
    mapping(uint256 => uint256) public claimedKWh;

    event RewardsClaimed(uint256 indexed tokenId, address indexed beneficiary, uint256 kWhClaimed, uint256 rewardAmount);
    event RequestVerification(bytes32 indexed requestId, uint256 indexed tokenId);
    event ProductionVerified(address indexed beneficiary, uint256 verifiedKWh, uint256 rewardAmount);

    constructor(address router) FunctionsClient(router) { _disableInitializers(); }

    function initialize(address _rewardToken, address _setupNFT, uint64 _subscriptionId, address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        require(_rewardToken != address(0), "Invalid token address");
        require(_setupNFT != address(0), "Invalid NFT address");
        rewardToken = IUnykornEnergyToken(_rewardToken);
        setupNFT = SolarSetupNFT(_setupNFT);
        subscriptionId = _subscriptionId;
    }

    function requestKWhVerification(uint256 tokenId, string memory solarID) external {
        require(setupNFT.ownerOf(tokenId) == msg.sender, "Caller does not own setup NFT");
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        string[] memory args = new string[](1);
        args[0] = solarID;
        req.setArgs(args);
        if (encryptedSecrets.length > 0) req.addSecretsReference(encryptedSecrets);
        lastRequestId = _sendRequest(req.encodeCBOR(), subscriptionId, 300_000, 0x66756e2d626e622d746573746e65742d31000000000000000000000000000000);
        requestToTokenId[lastRequestId] = tokenId;
        emit RequestVerification(lastRequestId, tokenId);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        if (err.length == 0) {
            uint256 verifiedKWh = abi.decode(response, (uint256));
            uint256 tokenId = requestToTokenId[requestId];
            address owner = setupNFT.ownerOf(tokenId);
            uint256 previousClaims = claimedKWh[tokenId];
            if (verifiedKWh > previousClaims) {
                uint256 newKWh = verifiedKWh - previousClaims;
                uint256 rewardAmount = (newKWh * 1e18) / 5;
                claimedKWh[tokenId] = verifiedKWh;
                rewardToken.mint(owner, rewardAmount);
                emit ProductionVerified(owner, newKWh, rewardAmount);
                emit RewardsClaimed(tokenId, owner, newKWh, rewardAmount);
            }
        }
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
