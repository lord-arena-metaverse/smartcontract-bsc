// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";

contract LordArenaStaking is Initializable , OwnableUpgradeable{
    
    constructor() initializer {}

    uint256 public constant YEAR_SECONDS = 31536000;
    address public STAKE_TOKEN;
    address public REWARD_TOKEN;

    struct StakingInfo {
        uint256 amount;
        uint256 stakingAt;
    } 

    uint256 public stakingInterestRate;
    
    mapping(address => StakingInfo) public listStaking;
    address public TREASURY_ADDRESS;

    function initialize() initializer public {
        __Ownable_init();
    }

    function updateConfig(
        uint32 _stakingInterestRate, address _stakeToken, address _rewardToken, address _treasury
    ) public onlyOwner returns (bool) {
        stakingInterestRate = _stakingInterestRate;
        STAKE_TOKEN = _stakeToken;
        REWARD_TOKEN = _rewardToken;
        TREASURY_ADDRESS = _treasury;
        return true;
    }

    function getReward(
        address _address
    ) public view returns (uint256) {
        uint256 yearReward = listStaking[_address].amount * stakingInterestRate / 100;
        uint256 amountReward =  yearReward * (block.timestamp - listStaking[_address].stakingAt) / YEAR_SECONDS;
        return (amountReward);
    }

    function staking(
        uint256 _amount
    ) public returns (bool) {
        // Return reward if user is staking
        if (listStaking[msg.sender].amount > 0) {
            uint256 reward = getReward(msg.sender);
            IERC20Upgradeable(REWARD_TOKEN).transferFrom(TREASURY_ADDRESS ,msg.sender, reward);
        }
        IERC20Upgradeable(STAKE_TOKEN).transferFrom(msg.sender, address(this), _amount);
        listStaking[msg.sender].amount += _amount;
        listStaking[msg.sender].stakingAt = block.timestamp;
        return true;
    }

    function unstaking(
        uint256 _amount
    ) public returns (bool) {
        require(listStaking[msg.sender].amount >= _amount, "Amount greater than staked amount.");
        // Return reward if amount = 0
        if (listStaking[msg.sender].amount > 0) {
            uint256 reward = getReward(msg.sender);
            IERC20Upgradeable(REWARD_TOKEN).transferFrom(TREASURY_ADDRESS ,msg.sender, reward);
        }
        if (_amount > 0) {
            IERC20Upgradeable(STAKE_TOKEN).transfer(msg.sender, _amount);
            listStaking[msg.sender].amount -= _amount;
            listStaking[msg.sender].stakingAt = block.timestamp;
        }
        
        return true;
    }


}