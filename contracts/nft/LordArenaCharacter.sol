// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependencies/open-zeppelin/token/ERC721/ERC721Upgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "../dependencies/open-zeppelin/security/PausableUpgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/utils/CountersUpgradeable.sol";
import "../dependencies/open-zeppelin/utils/StringsUpgradeable.sol";

contract LordArenaCharacter is
  Initializable,
  ERC721Upgradeable,
  ERC721URIStorageUpgradeable,
  PausableUpgradeable,
  OwnableUpgradeable,
  ERC721BurnableUpgradeable
{
  using CountersUpgradeable for CountersUpgradeable.Counter;

  CountersUpgradeable.Counter private _tokenIdCounter;

  struct CharacterInfo {
    uint256 nftID;
    uint256 level;
    uint256 characterID;
    uint256 quality; // 1 common, 2 rare, 3 rare+, 4 elite, 5 elite+, 6 legendary, 7 legendary+, 8 mythic, 9 mythic+, 10 immortal
  }

  mapping(uint256 => CharacterInfo) public properties;
  mapping(address => bool) public whitelistMinter;
  string public prefixURI;

  mapping(address => uint256[]) public tokensOfOwners;
  mapping(uint256 => uint256) public tokenIndexOfOwners;

  event NewCharacter(uint256 indexed equiment, address indexed minter);

  constructor() initializer {}

  function initialize() public initializer {
    __ERC721_init("Lord Arena Character", "LORDAC");
    __ERC721URIStorage_init();
    __Pausable_init();
    __Ownable_init();
    __ERC721Burnable_init();
  }

  modifier onlyWhitelistMinter() {
    require(whitelistMinter[msg.sender], "Invalid Minter");
    _;
  }

  modifier onlyNonContract {
    require(tx.origin == msg.sender, "Only non-contract call");
    _;
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function updateWhitelist(address _whitelist, bool _status) public onlyOwner {
    whitelistMinter[_whitelist] = _status;
  }

  function updatePrefixURI(string calldata _prefix) public onlyOwner {
    prefixURI = _prefix;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override whenNotPaused {
    _updateTokenOwner(from, to, tokenId);
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _updateTokenOwner(
    address from,
    address to,
    uint256 tokenId
  ) internal {
    if (from == address(0)) {
      tokensOfOwners[to].push(tokenId);
      tokenIndexOfOwners[tokenId] = tokensOfOwners[to].length - 1;
    } else {
      // remove nft of from address
      uint256 lastIndex = tokensOfOwners[from].length - 1;
      tokensOfOwners[from][tokenIndexOfOwners[tokenId]] = tokensOfOwners[from][lastIndex];
      tokenIndexOfOwners[tokensOfOwners[from][lastIndex]] = tokenIndexOfOwners[tokenId];
      tokensOfOwners[from].pop();
      // add nft for to address
      tokensOfOwners[to].push(tokenId);
      tokenIndexOfOwners[tokenId] = tokensOfOwners[to].length - 1;
    }
  }

  function safeMint(
    address to,
    uint256 _charId,
    uint256 _quality
  ) public onlyWhitelistMinter returns (uint256) {
    _safeMint(to, _tokenIdCounter.current());
    emit NewCharacter(_tokenIdCounter.current(), to);
    properties[_tokenIdCounter.current()].level = 1;
    properties[_tokenIdCounter.current()].characterID = _charId;
    properties[_tokenIdCounter.current()].nftID = _tokenIdCounter.current();
    properties[_tokenIdCounter.current()].quality = _quality;
    _tokenIdCounter.increment();
    return _tokenIdCounter.current() - 1;
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    returns (string memory)
  {
    return string(abi.encodePacked(prefixURI, StringsUpgradeable.toString(tokenId)));
  }

  function totalSupply() public view returns (uint256) {
    return (_tokenIdCounter.current());
  }

  function getTokenOwners(address _owner, uint256[] memory _selectedIdx) public view returns (CharacterInfo[] memory) {
    if (_selectedIdx.length > 0) {
      CharacterInfo[] memory nftInfos = new CharacterInfo[](_selectedIdx.length);
      for (uint256 i = 0; i < _selectedIdx.length; i++) {
        nftInfos[i] = properties[_selectedIdx[i]];
      }
      return nftInfos;
    } else {
      CharacterInfo[] memory nftInfos = new CharacterInfo[](tokensOfOwners[_owner].length);
      for (uint256 i = 0; i < tokensOfOwners[_owner].length; i++) {
        nftInfos[i] = properties[tokensOfOwners[_owner][i]];
      }
      return nftInfos;
    }
  }
}
