pragma solidity ^0.8.0;

import "../dependencies/open-zeppelin/token/ERC20/ERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";

contract LordArenaClaimTokenDev is Initializable, ERC20Upgradeable, OwnableUpgradeable {
  constructor() initializer {
    __ERC20_init("LordArena Claim Token Dev", "LACT");
    __Ownable_init();
  }

  function initialize() public initializer {}

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }
}
