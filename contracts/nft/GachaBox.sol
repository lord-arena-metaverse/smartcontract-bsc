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
  event NewBoxBUSD(
    address indexed minter,
    uint256 character1NFTId,
    uint256 character2NFTId,
    uint256 character3NFTId,
    uint256 indexed character5NFTId,
    uint256 indexed equipmentNFTId
  );
  event NewBoxLORDA(address indexed minter, uint256 indexed character5NFTId);

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

  function getCharacterIds()
    private
    view
    returns (uint256[4] memory characterIds, uint256[4] memory characterQualities)
  {
    uint8[13] memory characters = [8, 9, 10, 11, 20, 21, 22, 31, 32, 33, 41, 42, 43];

    for (uint8 i = 0; i < 4; i++) {
      uint256 characterIdx = RandomUtil(randomContract).getRandomNumber(characters.length - i);
      characterIds[i] = characters[characterIdx];
      characters[characters.length - i] = characters[characterIdx];

      uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(100);
      if (pctRnd <= 60) {
        characterQualities[i] = 2;
      } else {
        characterQualities[i] = 3;
      }
    }
  }

  function getSpecialCharacterNFTId() private returns (uint256 characterNFTId) {
    uint8[26] memory characters =
      [1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 25, 26, 27, 28, 29, 30, 36, 37, 38, 39, 40, 47, 48, 49];
    uint256 qualityId;

    uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(1000);
    if (pctRnd <= 5) {
      uint256 highRnd = RandomUtil(randomContract).getRandomNumber(2);
      qualityId = highRnd == 1 ? 9 : 10;
    } else if (pctRnd <= 10) {
      qualityId = 9;
    } else if (pctRnd <= 30) {
      qualityId = 7;
    } else if (pctRnd <= 150) {
      qualityId = 6;
    } else {
      qualityId = 5;
    }

    uint256 characterId = characters[RandomUtil(randomContract).getRandomNumber(characters.length - 1)];
    characterNFTId = ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterId, qualityId);
  }

  function genCharacterIdByLORDA() private view returns (uint256 characterId, uint256 qualityId) {
    uint8[8] memory commonCharacters = [12, 23, 34, 44, 13, 24, 35, 45];
    uint8[13] memory rareCharacters = [10, 41, 20, 31, 9, 43, 22, 32, 11, 42, 21, 33, 8];
    uint8[39] memory eliteCharacters =
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
        43,
        47,
        48,
        49
      ];

    uint256 pctRnd = RandomUtil(randomContract).getRandomNumber(100);
    if (pctRnd <= 8) {
      qualityId = 4;
      characterId = eliteCharacters[RandomUtil(randomContract).getRandomNumber(eliteCharacters.length - 1)];
    } else if (pctRnd <= 40) {
      qualityId = 1;
      characterId = commonCharacters[RandomUtil(randomContract).getRandomNumber(commonCharacters.length - 1)];
    } else {
      qualityId = 2;
      characterId = rareCharacters[RandomUtil(randomContract).getRandomNumber(rareCharacters.length - 1)];
    }
  }

  function openBoxByBUSD(uint256 _boxId)
    public
    onlyNonContract
    returns (
      uint256 character1NFTId,
      uint256 character2NFTId,
      uint256 character3NFTId,
      uint256 character4NFTId,
      uint256 character5NFTId,
      uint256 equipmentNFTId
    )
  {
    require(boxConfig[_boxId].totalSold <= boxConfig[_boxId].quota, "Box is full");
    require(boxConfig[_boxId].price > 0, "Invalid Box.");
    boxConfig[_boxId].totalSold += 1;
    IERC20Upgradeable(boxConfig[_boxId].currency).transferFrom(msg.sender, treasury, boxConfig[_boxId].price);

    uint256[4] memory characterNFTIds;
    (uint256[4] memory characterIds, uint256[4] memory characterQualities) = getCharacterIds();
    for (uint8 i = 0; i < 4; i++) {
      uint256 characterNFTId =
        ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterIds[i], characterQualities[i]);
      characterNFTIds[i] = characterNFTId;
    }
    character1NFTId = characterNFTIds[0];
    character2NFTId = characterNFTIds[1];
    character3NFTId = characterNFTIds[2];
    character4NFTId = characterNFTIds[3];
    character5NFTId = getSpecialCharacterNFTId();
    uint256 itemId = RandomUtil(randomContract).getRandomNumber(12);
    equipmentNFTId = ILordArenaEquipment(lordArenaItem).safeMint(msg.sender, itemId, 4);
    emit NewBoxBUSD(msg.sender, character1NFTId, character2NFTId, character3NFTId, character5NFTId, equipmentNFTId);
  }

  function openBoxByLORDA(uint256 _boxId) public onlyNonContract returns (uint256 characterNFTId) {
    require(boxConfig[_boxId].totalSold <= boxConfig[_boxId].quota, "Box is full");
    require(boxConfig[_boxId].price > 0, "Invalid Box.");
    boxConfig[_boxId].totalSold += 1;
    IERC20Upgradeable(boxConfig[_boxId].currency).transferFrom(msg.sender, treasury, boxConfig[_boxId].price);
    (uint256 characterId, uint256 qualityId) = genCharacterIdByLORDA();
    characterNFTId = ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterId, qualityId);
    emit NewBoxLORDA(msg.sender, characterNFTId);
  }
}
