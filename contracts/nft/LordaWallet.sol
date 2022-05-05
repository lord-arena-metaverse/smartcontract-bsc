// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";

contract LordaWallet is Initializable , OwnableUpgradeable{
    
    constructor() initializer {}

    mapping(address=>uint256) public depositTokenAddress;
    address public DEPOSIT_TOKEN;
    address public TREASURY_ADDRESS;

    event DepositToken(address indexed user, uint256 amount);

    function initialize() initializer public {
        __Ownable_init();
    }

    modifier onlyNonContract {
        require(tx.origin == msg.sender, "Only non-contract call");
        _;
    }

    // Update config
    function updateConfig(address _depositToken, address _treasury) public onlyOwner{
        DEPOSIT_TOKEN = _depositToken;
        TREASURY_ADDRESS = _treasury;
    }

    // Deposit 
    function depositToken(uint256 _depositAmount) public onlyNonContract {
        IERC20Upgradeable(DEPOSIT_TOKEN).transferFrom(msg.sender, TREASURY_ADDRESS, _depositAmount);
        depositTokenAddress[msg.sender] += _depositAmount;
        emit DepositToken(msg.sender, _depositAmount);
    }

}