// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../dependencies/open-zeppelin/token/ERC1155/ERC1155Upgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../utils/RandomUtil.sol";

contract LordArenaItem is
  Initializable,
  ERC1155Upgradeable,
  OwnableUpgradeable,
  ERC1155BurnableUpgradeable,
  ERC1155SupplyUpgradeable
{
  mapping(address => bool) public whitelistMinter;

  constructor() initializer {}

  function initialize() public initializer {
    __ERC1155_init("");
    __Ownable_init();
    __ERC1155Burnable_init();
    __ERC1155Supply_init();
  }

  event MintNewItem(address indexed account, uint256 itemId, uint256 amount);
  event MintNewBatchItem(address indexed account, uint256[] itemId, uint256[] amount);

  modifier onlyWhitelistMinter() {
    require(whitelistMinter[msg.sender], "Invalid Minter");
    _;
  }

  function updateWhitelist(address _whitelist, bool _status) public onlyOwner {
    whitelistMinter[_whitelist] = _status;
  }

  function setURI(string memory newuri) public onlyOwner {
    _setURI(newuri);
  }

  function mint(
    address account,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public onlyWhitelistMinter {
    _mint(account, id, amount, data);
    emit MintNewItem(account, id, amount);
  }

  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public onlyWhitelistMinter {
    _mintBatch(to, ids, amounts, data);
    emit MintNewBatchItem(to, ids, amounts);
  }

  // The following functions are overrides required by Solidity.

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override(ERC1155Upgradeable) {
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
  }

  function _burnBatch(
    address account,
    uint256[] memory ids,
    uint256[] memory amounts
  ) internal override(ERC1155SupplyUpgradeable, ERC1155Upgradeable) {
    super._burnBatch(account, ids, amounts);
  }

  function _burn(
    address account,
    uint256 id,
    uint256 amount
  ) internal override(ERC1155SupplyUpgradeable, ERC1155Upgradeable) {
    super._burn(account, id, amount);
  }

  function _mint(
    address account,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) internal override(ERC1155SupplyUpgradeable, ERC1155Upgradeable) {
    super._mint(account, id, amount, data);
  }

  function _mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal override(ERC1155SupplyUpgradeable, ERC1155Upgradeable) {
    super._mintBatch(to, ids, amounts, data);
  }
}
