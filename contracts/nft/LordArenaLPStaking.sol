// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";

contract LordArenaLPStaking is Initializable , OwnableUpgradeable{
    
    constructor() initializer {}

    address public STAKE_TOKEN;
    address public REWARD_TOKEN;
    uint256 emissionRate;

    struct StakingInfo {
        uint256 amount;
        uint256 stakingAt;
    } 

    
    mapping(address => StakingInfo) public listStaking;
    address public TREASURY_ADDRESS;

    function initialize() initializer public {
        __Ownable_init();
    }

    function updateConfig(
        address _stakeToken, address _rewardToken, address _treasury, uint256 _emissionRate
    ) public onlyOwner returns (bool) {
        STAKE_TOKEN = _stakeToken;
        REWARD_TOKEN = _rewardToken;
        TREASURY_ADDRESS = _treasury;
        emissionRate = _emissionRate;
        return true;
    }

    function getReward(
        address _address
    ) public view returns (uint256) {
        uint256 totalStaked = IERC20Upgradeable(STAKE_TOKEN).balanceOf(address(this));
        uint256 amountReward =  (block.timestamp - listStaking[_address].stakingAt) * emissionRate * listStaking[_address].amount / totalStaked;
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
            listStaking[msg.sender].stakingAt = block.timestamp;
        }
        if (_amount > 0) {
            IERC20Upgradeable(STAKE_TOKEN).transfer(msg.sender, _amount);
            listStaking[msg.sender].amount -= _amount;
            listStaking[msg.sender].stakingAt = block.timestamp;
        }
        return true;
    }


}