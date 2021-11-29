pragma solidity ^0.8.0;

import "../dependencies/open-zeppelin/token/ERC20/ERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";


contract LordArenaTokenDev is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    
    constructor () initializer {
        __ERC20_init("Lord Arena Token Dev", "LORDA");
        __Ownable_init();
    }

    function initialize() initializer public {
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }    
}