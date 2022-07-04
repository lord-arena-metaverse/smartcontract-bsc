pragma solidity ^0.8.0;

import "../dependencies/open-zeppelin/token/ERC20/ERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";

contract LordaDToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
  constructor() initializer {
    __ERC20_init("LordaD Token", "LordaD");
    __Ownable_init();
  }

  function initialize() public initializer {}

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }

/**
     * Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
  function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
  }


  /* ========== EMERGENCY ========== */
    function emergencySupport(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        ERC20Upgradeable(token).transfer(to, amount);
    }
}
