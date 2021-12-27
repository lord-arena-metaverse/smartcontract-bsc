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
    uint256 maxRewardCardNumber;
    address currency;
  }

  struct UserOpenBoxInfo {
    uint256 xBoxMissingEpicCount;
    uint256 YBoxMissingEpicCount;
    uint256 YBoxMissingLegendCount;
    uint256 ZBoxMissingLegendCount;
  }

  mapping(address => UserOpenBoxInfo) public userOpenInfo;
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
    boxConfig[_boxId].maxRewardCardNumber = _maxRewardCardNumber;
    boxConfig[_boxId].currency = _currencyToken;
  }

  function gachaXBox() public returns (uint256, uint256) {
    uint256 characterID = RandomUtil(randomContract).getRandomNumber(8);
    uint256 typeID; // 1: Normal, 2 Epic, 3 Legend
    if (userOpenInfo[msg.sender].xBoxMissingEpicCount >= 5) {
      typeID = 2;
      userOpenInfo[msg.sender].xBoxMissingEpicCount = 0;
    } else {
      uint256 randomValue = RandomUtil(randomContract).getRandomNumber(10000);
      if (randomValue >= 795) {
        typeID = 1;
        userOpenInfo[msg.sender].xBoxMissingEpicCount += 1;
      } else {
        typeID = 2;
        userOpenInfo[msg.sender].xBoxMissingEpicCount = 0;
      }
    }
    return (characterID, typeID);
  }

  function gachaYBox() public returns (uint256, uint256) {
    uint256 characterID = RandomUtil(randomContract).getRandomNumber(8);
    uint256 typeID; // 1: Normal, 2 Epic, 3 Legend
    if (userOpenInfo[msg.sender].YBoxMissingLegendCount >= 20) {
      typeID = 3;
      userOpenInfo[msg.sender].YBoxMissingLegendCount = 0;
    } else if (userOpenInfo[msg.sender].YBoxMissingEpicCount >= 5) {
      typeID = 2;
      userOpenInfo[msg.sender].YBoxMissingEpicCount = 0;
    } else {
      uint256 randomValue = RandomUtil(randomContract).getRandomNumber(10000);
      if (randomValue >= 4547) {
        typeID = 1;
        userOpenInfo[msg.sender].YBoxMissingLegendCount += 1;
        userOpenInfo[msg.sender].YBoxMissingEpicCount += 1;
      } else if (randomValue <= 85) {
        typeID = 2;
        userOpenInfo[msg.sender].YBoxMissingLegendCount += 1;
        userOpenInfo[msg.sender].YBoxMissingEpicCount = 0;
      } else {
        typeID = 3;
        userOpenInfo[msg.sender].YBoxMissingLegendCount = 0;
        userOpenInfo[msg.sender].YBoxMissingEpicCount += 1;
      }
    }
    return (characterID, typeID);
  }

  function gachaZBox() public returns (uint256, uint256) {
    uint256 characterID = RandomUtil(randomContract).getRandomNumber(8);
    uint256 typeID; // 1: Normal, 2 Epic, 3 Legend
    if (userOpenInfo[msg.sender].ZBoxMissingLegendCount >= 3) {
      typeID = 3;
      userOpenInfo[msg.sender].ZBoxMissingLegendCount = 0;
    } else {
      uint256 randomValue = RandomUtil(randomContract).getRandomNumber(10000);
      if (randomValue >= 2535) {
        typeID = 2;
        userOpenInfo[msg.sender].ZBoxMissingLegendCount += 1;
      } else {
        typeID = 3;
        userOpenInfo[msg.sender].ZBoxMissingLegendCount = 0;
      }
    }
    return (characterID, typeID);
  }

  function getRelatedCard(uint256 characterID, uint256 typeID) public pure returns (uint256) {
    uint256 cardID;
    if (typeID == 1) {
      if (characterID == 1) {
        cardID = 1;
      } else if (characterID == 2) {
        cardID = 2;
      } else if (characterID == 3) {
        cardID = 3;
      } else if (characterID == 4) {
        cardID = 4;
      } else if (characterID == 5) {
        cardID = 5;
      } else if (characterID == 6) {
        cardID = 6;
      } else if (characterID == 7) {
        cardID = 7;
      } else if (characterID == 8) {
        cardID = 8;
      }
    } else if (typeID == 2) {
      if (characterID == 1) {
        cardID = 9;
      } else if (characterID == 2) {
        cardID = 10;
      } else if (characterID == 3) {
        cardID = 11;
      } else if (characterID == 4) {
        cardID = 12;
      } else if (characterID == 5) {
        cardID = 13;
      } else if (characterID == 6) {
        cardID = 14;
      } else if (characterID == 7) {
        cardID = 15;
      } else if (characterID == 8) {
        cardID = 16;
      }
    } else if (typeID == 3) {
      if (characterID == 1) {
        cardID = 17;
      } else if (characterID == 2) {
        cardID = 18;
      } else if (characterID == 3) {
        cardID = 19;
      } else if (characterID == 4) {
        cardID = 20;
      } else if (characterID == 5) {
        cardID = 21;
      } else if (characterID == 6) {
        cardID = 22;
      } else if (characterID == 7) {
        cardID = 23;
      } else if (characterID == 8) {
        cardID = 24;
      }
    }
    return cardID;
  }

  function getRewardCardBox(uint256 boxID, uint256 totalNFT) public pure returns (uint256[] memory) {
    uint256[6] memory amount;
    if (boxID == 1) {
      if (totalNFT <= 1) {
        amount = [uint256(20), 0, 0, 0, 0, 0];
      } else if (totalNFT <= 2) {
        amount = [uint256(10), 15, 0, 0, 0, 0];
      } else if (totalNFT <= 3) {
        amount = [uint256(10), 10, 10, 0, 0, 0];
      } else if (totalNFT <= 4) {
        amount = [uint256(5), 10, 10, 10, 0, 0];
      } else {
        amount = [uint256(10), 10, 10, 10, 0, 0];
      }
    } else if (boxID == 2) {
      if (totalNFT <= 1) {
        amount = [uint256(50), 0, 0, 0, 0, 0];
      } else if (totalNFT <= 2) {
        amount = [uint256(25), 30, 0, 0, 0, 0];
      } else if (totalNFT <= 3) {
        amount = [uint256(10), 20, 30, 0, 0, 0];
      } else if (totalNFT <= 4) {
        amount = [uint256(15), 15, 15, 25, 0, 0];
      } else if (totalNFT <= 5) {
        amount = [uint256(10), 10, 15, 15, 20, 0];
      } else if (totalNFT <= 6) {
        amount = [uint256(10), 15, 15, 15, 20, 0];
      } else {
        amount = [uint256(15), 15, 15, 15, 20, 0];
      }
    } else {
      if (totalNFT <= 1) {
        amount = [uint256(100), 0, 0, 0, 0, 0];
      } else if (totalNFT <= 2) {
        amount = [uint256(50), 60, 0, 0, 0, 0];
      } else if (totalNFT <= 3) {
        amount = [uint256(30), 40, 50, 0, 0, 0];
      } else if (totalNFT <= 4) {
        amount = [uint256(30), 30, 30, 40, 0, 0];
      } else if (totalNFT <= 5) {
        amount = [uint256(20), 20, 30, 30, 40, 0];
      } else if (totalNFT <= 6) {
        amount = [uint256(15), 15, 25, 25, 35, 35];
      } else if (totalNFT <= 7) {
        amount = [uint256(20), 20, 25, 25, 35, 35];
      } else if (totalNFT <= 8) {
        amount = [uint256(20), 20, 30, 30, 35, 35];
      } else {
        amount = [uint256(20), 20, 30, 30, 40, 40];
      }
    }
    uint256 lengthAmount = 6;
    for (uint256 i = 0; i < amount.length; i++) {
      if (amount[i] == 0) {
        lengthAmount--;
      }
    }

    uint256 index = 0;
    uint256[] memory result = new uint256[](lengthAmount);
    for (uint256 i = 0; i < amount.length; i++) {
      if (amount[i] != 0) {
        result[index] = amount[i];
        index++;
      }
    }
    return (result);
  }

  function getRewardNFTCard(uint256 boxID, address _sender) public view returns (uint256[] memory) {
    // Gacha fighter card
    uint256[] memory totalIdx = new uint256[](ILordArenaCharacter(lordArenaCharacter).balanceOf(_sender));
    uint256 selectNumber;
    bool needRandom = false;
    if (boxID == 1) {
      if (totalIdx.length < 5) {
        selectNumber = totalIdx.length;
      } else if (totalIdx.length == 5) {
        selectNumber = 4;
      } else {
        selectNumber = 4;
        needRandom = true;
      }
    } else if (boxID == 2) {
      if (totalIdx.length < 6) {
        selectNumber = totalIdx.length;
      } else {
        selectNumber = 5;
        needRandom = true;
      }
    } else {
      if (totalIdx.length < 7) {
        selectNumber = totalIdx.length;
      } else {
        selectNumber = 6;
        needRandom = true;
      }
    }

    for (uint256 i = 0; i < totalIdx.length; i++) {
      totalIdx[i] = i;
    }
    uint256[] memory rewardNft = new uint256[](selectNumber);
    for (uint256 i = 0; i < selectNumber; i++) {
      if (needRandom) {
        uint256 rewardIndex = RandomUtil(randomContract).getRandomNumber(totalIdx.length - i) - 1;
        rewardNft[i] = ILordArenaCharacter(lordArenaCharacter).tokensOfOwners(_sender, rewardIndex);
        totalIdx[rewardIndex] = totalIdx[totalIdx.length - 1 - i];
      } else {
        rewardNft[i] = ILordArenaCharacter(lordArenaCharacter).tokensOfOwners(_sender, i);
      }
    }
    return rewardNft;
  }

  // Open box
  function openBox(uint256 _boxId) public onlyNonContract returns (uint256) {
    require(boxConfig[_boxId].totalSold <= boxConfig[_boxId].quota, "Exceed mint quota.");
    require(boxConfig[_boxId].price > 0, "Invalid Box.");
    boxConfig[_boxId].totalSold += 1;
    IERC20Upgradeable(boxConfig[_boxId].currency).transferFrom(msg.sender, treasury, boxConfig[_boxId].price);
    uint256 characterID;
    uint256 typeID;
    // XBox = 1, YBox = 2, ZBox = 3
    uint256 totalNFT = ILordArenaCharacter(lordArenaCharacter).balanceOf(msg.sender);
    if (_boxId == 1) {
      (characterID, typeID) = gachaXBox();
    } else if (_boxId == 2) {
      (characterID, typeID) = gachaYBox();
    } else {
      (characterID, typeID) = gachaZBox();
    }
    if (totalNFT == 0) {
      uint256 nftID = ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterID, typeID);
      return nftID;
    } else {
      uint256[] memory amountCard = getRewardCardBox(_boxId, totalNFT);
      uint256[] memory reChaIdx = getRewardNFTCard(_boxId, msg.sender);
      ILordArenaCharacter.CharacterInfo[] memory reNft =
        ILordArenaCharacter(lordArenaCharacter).getTokenOwners(msg.sender, reChaIdx);
      uint256[] memory rewrardID = new uint256[](reChaIdx.length);
      for (uint256 i = 0; i < reChaIdx.length; i++) {
        rewrardID[i] = getRelatedCard(reNft[i].characterID, reNft[i].typeID);
      }
      ILordArenaItem(lordArenaItem).mintBatch(msg.sender, rewrardID, amountCard, "");
      uint256 nftID = ILordArenaCharacter(lordArenaCharacter).safeMint(msg.sender, characterID, typeID);
      return nftID;
    }
  }
}
