// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/utils/CountersUpgradeable.sol";
import "../dependencies/open-zeppelin/utils/math/SafeMathUpgradeable.sol";
import "../dependencies/open-zeppelin/security//ReentrancyGuardUpgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC721/IERC721Upgradeable.sol";

import "../interfaces/ILordArenaCharacter.sol";

contract LordArenaMarket is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter public _itemIds;
  CountersUpgradeable.Counter public _itemsSold;

  mapping(address => bool) public whitelistNFT;
  address public treasury;

  struct MarketItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address seller;
    address owner;
    uint256 price;
    address currencyToken;
  }

  mapping(uint256 => MarketItem) private idToMarketItem;
  mapping(address => bool) public whitelistCurrency;
  mapping(address => uint256) public currencyFee;

  constructor() initializer {}

  function initialize() public initializer {
    __Ownable_init();
    __ReentrancyGuard_init();
  }

  event MarketItemUpdate(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    uint256 timestamp,
    address currencyToken
  );

  // Update config
  function updateConfig(address _treasury) public onlyOwner {
    treasury = _treasury;
  }

  // Update fee currency
  function updateCurrencyFee(uint256 _feeRate, address _currencyToken) public onlyOwner {
    currencyFee[_currencyToken] = _feeRate;
  }

  // Update nft token
  function updateNFTToken(address _nftToken, bool _status) public onlyOwner {
    whitelistNFT[_nftToken] = _status;
  }

  // Update currency token
  function updateCurrencyToken(address _currencyToken, bool _status) public onlyOwner {
    whitelistCurrency[_currencyToken] = _status;
  }

  function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
    return idToMarketItem[marketItemId];
  }

  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    uint256 price,
    address currencyToken
  ) public nonReentrant {
    require(whitelistNFT[nftContract], "Invalid NFT.");
    require(whitelistCurrency[currencyToken], "Invalid currency token.");
    require(price > 0, "Price must be at least 1 wei");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();

    idToMarketItem[itemId] = MarketItem(itemId, nftContract, tokenId, msg.sender, address(0), price, currencyToken);

    IERC721Upgradeable(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit MarketItemUpdate(itemId, nftContract, tokenId, msg.sender, address(0), price, block.timestamp, currencyToken);
  }

  function updateMarketPrice(uint256 itemId, uint256 price) public nonReentrant {
    require(idToMarketItem[itemId].seller == msg.sender, "Invalid seller.");
    require(idToMarketItem[itemId].owner == address(0), "This item already sold.");
    require(idToMarketItem[itemId].price > 0, "This item already delisted.");
    idToMarketItem[itemId].price = price;

    emit MarketItemUpdate(
      itemId,
      idToMarketItem[itemId].nftContract,
      idToMarketItem[itemId].tokenId,
      idToMarketItem[itemId].seller,
      idToMarketItem[itemId].owner,
      idToMarketItem[itemId].price,
      block.timestamp,
      idToMarketItem[itemId].currencyToken
    );
  }

  function cancelListingMarket(uint256 itemId) public nonReentrant {
    require(idToMarketItem[itemId].seller == msg.sender, "Invalid seller.");
    require(idToMarketItem[itemId].owner == address(0), "Order might be sold or delisted. Please wait for a few minutes and try again.");
    require(idToMarketItem[itemId].price > 0, "This item already sold.");
    IERC721Upgradeable(idToMarketItem[itemId].nftContract).transferFrom(
      address(this),
      msg.sender,
      idToMarketItem[itemId].tokenId
    );
    idToMarketItem[itemId].price = 0;
    emit MarketItemUpdate(
      itemId,
      idToMarketItem[itemId].nftContract,
      idToMarketItem[itemId].tokenId,
      idToMarketItem[itemId].seller,
      idToMarketItem[itemId].owner,
      idToMarketItem[itemId].price,
      block.timestamp,
      idToMarketItem[itemId].currencyToken
    );
  }

  function createMarketSale(uint256 itemId, uint256 _price) public nonReentrant {
    require(idToMarketItem[itemId].owner == address(0), "Order might be sold or delisted. Please wait for a few minutes and try again.");
    require(idToMarketItem[itemId].price > 0, "This item already delisted.");
    require(idToMarketItem[itemId].price == _price, "Invalid Price.");
    uint256 price = idToMarketItem[itemId].price;
    uint256 tokenId = idToMarketItem[itemId].tokenId;
    idToMarketItem[itemId].owner = msg.sender;
    uint256 fee = (price * currencyFee[idToMarketItem[itemId].currencyToken]) / 1000;
    if (fee > 0) {
      IERC20Upgradeable(idToMarketItem[itemId].currencyToken).transferFrom(msg.sender, treasury, fee);
    }

    IERC20Upgradeable(idToMarketItem[itemId].currencyToken).transferFrom(
      msg.sender,
      idToMarketItem[itemId].seller,
      price - fee
    );
    IERC721Upgradeable(idToMarketItem[itemId].nftContract).transferFrom(address(this), msg.sender, tokenId);
    _itemsSold.increment();

    emit MarketItemUpdate(
      itemId,
      idToMarketItem[itemId].nftContract,
      tokenId,
      idToMarketItem[itemId].seller,
      msg.sender,
      price,
      block.timestamp,
      idToMarketItem[itemId].currencyToken
    );
  }
}
