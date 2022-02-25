// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/utils/ContextUpgradeable.sol";

contract LORDAVesting is OwnableUpgradeable {
    IERC20Upgradeable public immutable _lorda;

    uint256 public immutable _tgePercentage;
    uint256 public immutable _cliffPercentage;
    uint256 public immutable _startTime;
    uint256 public immutable _claimTime;
    uint256 public immutable _endTime;
    uint256 public immutable _periods;

    uint256 public _totalLocked;
    uint256 public _totalReleased;
    uint256 public _totalUsers;

    mapping(address => bool) private _whitelist;
    mapping(address => uint256) private _locked;
    mapping(address => uint256) private _released;

    Stage public _stage;

    enum Stage {
        PENDING,
        WHITELISTING,
        CLAIM,
        CLOSE
    }

    event WhitelisterAdded(address indexed user, uint256 amount);

    event Claimed(address indexed account, uint256 amount, uint256 time);

    // LORDA = 0xc326622FcA914CA15fD44DD070232cE3cd358Dde
    constructor(
        address lorda,
        uint256 tgePercentage,
        uint256 cliffPercentage,
        uint256 startTime,
        uint256 claimTime,
        uint256 endTime,
        uint256 periods
    ) {
        _lorda = IERC20Upgradeable(lorda);
        _tgePercentage = tgePercentage;
        _cliffPercentage = cliffPercentage;
        _startTime = startTime;
        _claimTime = claimTime;
        _endTime = endTime;
        _periods = periods;

        _stage = Stage.PENDING;
    }

    modifier canAddWhitelister() {
        require(_stage == Stage.WHITELISTING, "Cannot add whitelister now");
        _;
    }

    modifier canClaim() {
        require(_stage == Stage.CLAIM, "Cannot claim now");
        _;
    }

    function changeStage(Stage stage) public onlyOwner {
        require(stage > _stage, "Cannot change stage");
        _stage = stage;
    }

    modifier onlyWhitelister() {
        require(_whitelist[_msgSender()], "Not in whitelist");
        _;
    }

    function addWhitelisters(
        address[] calldata users,
        uint256[] calldata amounts
    ) external onlyOwner canAddWhitelister {
        require(users.length == amounts.length, "Input invalid");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < users.length; i++) {
            if (_locked[users[i]] == 0) {
                _totalUsers += 1;
            }

            _locked[users[i]] += amounts[i];
            _totalLocked += amounts[i];
            totalAmount += amounts[i];

            _whitelist[users[i]] = true;

            emit WhitelisterAdded(users[i], amounts[i]);
        }

        _lorda.transferFrom(_msgSender(), address(this), totalAmount);
    }

    function claim() external onlyWhitelister canClaim {
        require(block.timestamp >= _startTime, "Still locked");
        require(_locked[_msgSender()] > _released[_msgSender()], "No locked");

        uint256 amount = _claimableAmount(_msgSender());
        require(amount > 0, "Nothing to claim");

        _released[_msgSender()] += amount;

        _lorda.transfer(_msgSender(), amount);

        _totalLocked -= amount;
        _totalReleased += amount;

        emit Claimed(_msgSender(), amount, block.timestamp);
    }

    function _claimableAmount(address account) private view returns (uint256) {
        if (block.timestamp < _startTime) {
            return 0;
        } else if (block.timestamp < _claimTime) {
            uint256 tgeUnlock = (_locked[account] * _tgePercentage) / 10000;

            return tgeUnlock - _released[account];
        } else if (block.timestamp >= _endTime) {
            return _locked[account] - _released[account];
        } else {
            uint256 passedPeriods = _passedPeriods();
            uint256 unlockAmount = (_locked[account] *
                (_tgePercentage + _cliffPercentage)) / 10000;

            return
                unlockAmount +
                (((_locked[account] - unlockAmount) * passedPeriods) /
                    _periods) -
                _released[account];
        }
    }

    function _passedPeriods() private view returns (uint256) {
        return
            (block.timestamp >= _endTime)
                ? _periods
                : ((block.timestamp - _claimTime) * _periods) /
                    (_endTime - _claimTime);
    }

    /* For FE
        0: isWhitelister
        1: locked amount
        2: released amount
        3: claimable amount
    */
    function infoWallet(address user)
        public
        view
        returns (
            bool,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            _whitelist[user],
            _locked[user],
            _released[user],
            _claimableAmount(user)
        );
    }

    /* ========== EMERGENCY ========== */
    function governanceRecoverUnsupported(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20Upgradeable(token).transfer(to, amount);
    }
}
