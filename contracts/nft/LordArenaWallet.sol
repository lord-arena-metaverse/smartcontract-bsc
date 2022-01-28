// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";

contract LordArenaWallet is Initializable, OwnableUpgradeable {
  constructor() initializer {}

  mapping(address => uint256) public depositAddress;
  address public TOKEN_ADDRESS;
  address public TREASURY_ADDRESS;

  event DepositTokenEvent(address indexed user, uint256 amount);

  function initialize() public initializer {
    __Ownable_init();
  }

  modifier onlyNonContract {
    require(tx.origin == msg.sender, "Only non-contract call.");
    _;
  }

  // Update config
  function updateConfig(address _tokenAddress, address _treasury) public onlyOwner {
    TOKEN_ADDRESS = _tokenAddress;
    TREASURY_ADDRESS = _treasury;
  }

  function deposit(uint256 _depositAmount) public onlyNonContract {
    IERC20Upgradeable(TOKEN_ADDRESS).transferFrom(msg.sender, TREASURY_ADDRESS, _depositAmount);
    depositAddress[msg.sender] += _depositAmount;
    emit DepositTokenEvent(msg.sender, _depositAmount);
  }
}
