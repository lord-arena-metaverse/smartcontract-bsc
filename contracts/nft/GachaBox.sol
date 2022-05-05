// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../interfaces/ILordArenaCharacter.sol";
import "../interfaces/ILordArenaEquipment.sol";
import "../utils/RandomUtil.sol";

contract GachaBox is Initializable, OwnableUpgradeable {
  constructor() initializer {}

  struct BoxInfo {
    uint256 quota;
    uint256 totalSold;
    uint256 price;
    address currency;
    uint256 maxRewardCardNumber;
  }

  mapping(uint256 => BoxInfo) public boxConfig;
  address public lordArenaCharacter;
  address public lordArenaItem;
  address public treasury;
  address public buyToken;
  address private randomContract;

  function initialize() public initializer {
    __Ownable_init();
  }

  modifier onlyNonContract {
    require(tx.origin == msg.sender, "Only non-contract call");
    _;
  }

  // Update config
  function updateConfig(
    address _lordArenaCharacter,
    address _lordArenaItem,
    address _treasury,
    address _randomContract
  ) public onlyOwner {
    lordArenaCharacter = _lordArenaCharacter;
    lordArenaItem = _lordArenaItem;
    treasury = _treasury;
    randomContract = _randomContract;
  }

  // Update boxConfig
  function updateBoxConfig(
    uint256 _quota,
    uint256 _price,
    uint256 _boxId,
    uint256 _maxRewardCardNumber,
    address _currencyToken
  ) public onlyOwner {
    require(_boxId != 0, "Invalid boxId");
    require(_boxId < 4, "Invalid boxId");
    boxConfig[_boxId].quota = _quota;
    boxConfig[_boxId].price = _price;
    boxConfig[_boxId].currency = _currencyToken;
    boxConfig[_boxId].maxRewardCardNumber = _maxRewardCardNumber;
  }

  function getSpecialCharacterNFTIdByLORDA() public view returns (uint256, uint256) {
    uint8[26] memory characters =
      [1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 25, 26, 27, 28, 29, 30, 36, 37, 38, 39, 40, 47, 48, 49];
    uint256 qualityId;

    uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(1000);
    if (pctRnd <= 5) {
      uint256 highRnd = RandomUtil(randomContract).getRandomNumber(2);
      qualityId = highRnd == 1 ? 9 : 10;
    } else if (pctRnd <= 10) {
      qualityId = 8;
    } else if (pctRnd <= 30) {
      qualityId = 7;
    } else if (pctRnd <= 150) {
      qualityId = 6;
    } else {
      qualityId = 5;
    }

    uint256 characterId = characters[RandomUtil(randomContract).getRandomNumber(characters.length - 1)];
    return (characterId, qualityId);
  }

  function getSpecialCharacterNFTIdByBUSD() public view returns (uint256, uint256) {
    uint8[26] memory characters =
      [1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 25, 26, 27, 28, 29, 30, 36, 37, 38, 39, 40, 47, 48, 49];
    uint256 qualityId;

    uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(10000);
    if (pctRnd <= 25) {
      uint256 highRnd = RandomUtil(randomContract).getRandomNumber(2);
      qualityId = highRnd == 1 ? 9 : 10;
    } else if (pctRnd <= 150) {
      qualityId = 8;
    } else if (pctRnd <= 300) {
      qualityId = 7;
    } else if (pctRnd <= 1000) {
      qualityId = 6;
    } else {
      qualityId = 5;
    }

    uint256 characterId = characters[RandomUtil(randomContract).getRandomNumber(characters.length - 1)];
    return (characterId, qualityId);
  }

  function openBoxByLORDA() public onlyNonContract {
    require(boxConfig[1].totalSold <= boxConfig[1].quota, "Box is full.");
    require(boxConfig[1].price > 0, "Invalid Box.");
    boxConfig[1].totalSold += 1;
    IERC20Upgradeable(boxConfig[1].currency).transferFrom(msg.sender, treasury, boxConfig[1].price);

    uint256[13] memory characters = [uint256(8), 9, 10, 11, 20, 21, 22, 31, 32, 33, 41, 42, 43];

    for (uint256 i = 0; i < 4; i++) {
      uint256 characterQuality;
      uint256 characterIdx = RandomUtil(randomContract).getRandomNumber(characters.length - i);
      characters[characterIdx] = characters[characters.length - i - 1];

      uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(100);
      if (pctRnd <= 60) {
        characterQuality = 2;
      } else {
        characterQuality = 3;
      }
      ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characters[characterIdx], characterQuality);
      uint256 equipmentId = RandomUtil(randomContract).getRandomNumber(12);
      ILordArenaEquipment(lordArenaItem).safeMint(msg.sender, equipmentId, 4);
    }
    (uint256 nftID, uint256 qualityId) = getSpecialCharacterNFTIdByLORDA();
    ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, nftID, qualityId);
    uint256 itemId = RandomUtil(randomContract).getRandomNumber(12);
    ILordArenaEquipment(lordArenaItem).safeMint(msg.sender, itemId, 4);
  }

  function openBoxByBUSD() public onlyNonContract {
    require(boxConfig[2].totalSold <= boxConfig[2].quota, "Box is full");
    require(boxConfig[2].price > 0, "Invalid Box.");
    boxConfig[2].totalSold += 1;
    IERC20Upgradeable(boxConfig[2].currency).transferFrom(msg.sender, treasury, boxConfig[2].price);

    uint256[13] memory characters = [uint256(8), 9, 10, 11, 20, 21, 22, 31, 32, 33, 41, 42, 43];

    for (uint256 i = 0; i < 4; i++) {
      uint256 characterQuality;
      uint256 characterIdx = RandomUtil(randomContract).getRandomNumber(characters.length - i);
      characters[characterIdx] = characters[characters.length - i - 1];

      uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(100);
      if (pctRnd <= 70) {
        characterQuality = 2;
      } else {
        characterQuality = 3;
      }
      ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characters[characterIdx], characterQuality);
      uint256 equipmentId = RandomUtil(randomContract).getRandomNumber(12);
      ILordArenaEquipment(lordArenaItem).safeMint(msg.sender, equipmentId, 4);
    }
    (uint256 nftID, uint256 qualityId) = getSpecialCharacterNFTIdByBUSD();
    ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, nftID, qualityId);
    uint256 itemId = RandomUtil(randomContract).getRandomNumber(12);
    ILordArenaEquipment(lordArenaItem).safeMint(msg.sender, itemId, 4);
  }
}
