// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../interfaces/ILordArenaCharacter.sol";
import "../interfaces/ILordArenaItem.sol";
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

  function getCharacterNFTId() public returns (uint256[4] memory characterNFTIds) {
    uint8[13] memory characters = [8, 9, 10, 11, 20, 21, 22, 31, 32, 33, 41, 42, 43];
    uint8[2] memory qualities = [2, 3];
    uint256 characterIdQuality;

    for (uint8 i = 0; i < 4; i++) {
      uint256 characterIdx = RandomUtil(randomContract).getRandomNumber(characters.length - i);
      characters[characters.length - i] = characters[characterIdx];

      uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(100);
      if (pctRnd <= 60) {
        characterIdQuality = qualities[0];
      } else {
        characterIdQuality = qualities[1];
      }

      uint256 characterNFTId =
        ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characters[characterIdx], characterIdQuality);
      characterNFTIds[i] = characterNFTId;
    }
  }

  function getSpecialCharacterNFTId() public returns (uint256) {
    uint8[26] memory characters =
      [1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 25, 26, 27, 28, 29, 30, 36, 37, 38, 39, 40, 47, 48, 49];
    uint8[6] memory qualities = [5, 6, 7, 8, 9, 10];
    uint256 characterIdQuality;

    uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(1000);
    if (pctRnd <= 5) {
      uint256 highRnd = RandomUtil(randomContract).getRandomNumber(2);
      characterIdQuality = highRnd == 1 ? qualities[4] : qualities[5];
    } else if (pctRnd > 5 && pctRnd <= 10) {
      characterIdQuality = qualities[3];
    } else if (pctRnd > 10 && pctRnd <= 30) {
      characterIdQuality = qualities[2];
    } else if (pctRnd > 30 && pctRnd <= 150) {
      characterIdQuality = qualities[1];
    } else {
      characterIdQuality = qualities[0];
    }

    uint256 characterId = characters[RandomUtil(randomContract).getRandomNumber(characters.length - 1)];
    uint256 characterNFTId =
      ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterId, characterIdQuality);
    return characterNFTId;
  }

  function genCharacters()
    public
    returns (
      uint256 character1NFTId,
      uint256 character2NFTId,
      uint256 character3NFTId,
      uint256 character4NFTId,
      uint256 character5NFTId
    )
  {
    // random 4 character with quality rare and rare+
    uint256[4] memory characterNFTIds = getCharacterNFTId();
    character1NFTId = characterNFTIds[0];
    character2NFTId = characterNFTIds[1];
    character3NFTId = characterNFTIds[2];
    character4NFTId = characterNFTIds[3];
    character5NFTId = getSpecialCharacterNFTId();
  }

  function genCharacterByBUSD() public returns (uint256) {
    uint8[36] memory characters =
      [
        1,
        2,
        3,
        4,
        5,
        6,
        8,
        9,
        10,
        11,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
        33,
        36,
        37,
        38,
        39,
        40,
        41,
        42,
        43
      ];
    uint8[3] memory qualities = [2, 3, 4]; // 1 common, 2 rare, 3 rare+, 4 elite, 5 elite+, 6 legendary, 7 legendary+, 8 mythic, 9 mythic+, 10
    uint256 characterId = characters[RandomUtil(randomContract).getRandomNumber(characters.length - 1)];
    uint256 characterIdQuality = qualities[RandomUtil(randomContract).getRandomNumber(qualities.length - 1)];
    uint256 characterNFTId =
      ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterId, characterIdQuality);
    return characterNFTId;
  }

  function openBoxByLORDA(uint256 _boxId)
    public
    onlyNonContract
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    require(boxConfig[_boxId].totalSold <= boxConfig[_boxId].quota, "Box is full");
    require(boxConfig[_boxId].price > 0, "Invalid Box.");
    boxConfig[_boxId].totalSold += _boxId;
    IERC20Upgradeable(boxConfig[_boxId].currency).transferFrom(msg.sender, treasury, boxConfig[_boxId].price);
    uint256 character1;
    uint256 character2;
    uint256 character3;
    uint256 character4;
    uint256 character5;
    (character1, character2, character3, character4, character5) = genCharacters();
    return (character1, character2, character3, character4, character5);
  }

  function openBoxByBUSD(uint256 _boxId) public onlyNonContract returns (uint256 characterNFTId) {
    require(boxConfig[_boxId].totalSold <= boxConfig[_boxId].quota, "Box is full");
    require(boxConfig[_boxId].price > 0, "Invalid Box.");
    boxConfig[_boxId].totalSold += _boxId;
    IERC20Upgradeable(boxConfig[_boxId].currency).transferFrom(msg.sender, treasury, boxConfig[_boxId].price);
    characterNFTId = genCharacterByBUSD();
    return characterNFTId;
  }
}
