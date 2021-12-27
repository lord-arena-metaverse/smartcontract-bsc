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
  }

  mapping(uint256 => BoxInfo) public boxConfig;
  address public lordArenaCharacter;
  address public lordArenaItem;
  address public treasury;
  address public buyToken;
  address private randomContract;

  uint8[13] typeIds = [3, 1, 1, 1, 3, 3, 2, 2, 1, 2, 1, 3, 2];
  uint8[13] factionIds = [1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1];
  uint8[6] specialQualities = [5, 6, 7, 8, 9, 10];

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
  }

  function getCharacterInfo(uint256 _characterId) public view returns (uint256, uint256) {
    require(_characterId <= 0, "Invalid characterId");
    require(_characterId > 13, "Invalid characterId");

    return (typeIds[_characterId - 1], factionIds[_characterId - 1]);
  }

  function getCharacterNFTId(uint256 ignoreId, bool isSpecialCharacter) public returns (uint256) {
    uint8[13] memory characters = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    uint8[2] memory qualities = [2, 3];
    uint256 typeId;
    uint256 factionId;

    if (ignoreId > 0 && ignoreId <= 13) {
      delete characters[ignoreId - 1];
    }

    uint256 characterId = RandomUtil(randomContract).getRandomNumber(characters.length - 1);
    uint256 characterIdQuality =
      RandomUtil(randomContract).getRandomNumber(
        isSpecialCharacter ? specialQualities.length - 1 : qualities.length - 1
      );
    (typeId, factionId) = getCharacterInfo(characterId);
    uint256 characterNFTId =
      ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterId, typeId, characterIdQuality, factionId);
    return characterNFTId;
  }

  function genCharacters()
    public
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    // random 4 character with quality rare and rare+
    uint256 character1NFTId = getCharacterNFTId(0, false);
    uint256 character2NFTId = getCharacterNFTId(character1NFTId, false);
    uint256 character3NFTId = getCharacterNFTId(character2NFTId, false);
    uint256 character4NFTId = getCharacterNFTId(character3NFTId, false);

    // random 1 special character with quality gte elite+
    uint256 character5NFTId = getCharacterNFTId(character3NFTId, true);

    return (character1NFTId, character2NFTId, character3NFTId, character4NFTId, character5NFTId);
  }

  function openBox(uint256 _boxId)
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
}