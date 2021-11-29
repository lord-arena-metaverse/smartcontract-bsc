// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../dependencies/open-zeppelin/utils/StringsUpgradeable.sol";

contract RandomUtil is Initializable , OwnableUpgradeable{
    
    constructor() initializer {}

    uint256 randomCounter;
    mapping(address => bool) public whitelistRandom;  

    function initialize() initializer public {
        __Ownable_init();
    }

    modifier onlyWhitelistRandom() {
        require(whitelistRandom[msg.sender], 'Only whitelist');
        _;
    }

    function getRandomSeed() internal view returns (uint256) {
        return uint256(sha256(abi.encodePacked(block.coinbase, randomCounter, blockhash(block.number -1), block.difficulty, block.gaslimit, block.timestamp, gasleft(), msg.sender)));
    }

    function setWhiteList(address _whitelist, bool status) public onlyOwner {
        whitelistRandom[_whitelist] = status;
    }

    // Get random number
    function updateCounter(uint256 addedCounter) public onlyWhitelistRandom{
        unchecked { randomCounter += addedCounter; }
    }

    // Get random number
    function getRandomNumber(uint256 _rate) public view onlyWhitelistRandom returns (uint256) {
        return (getRandomSeed() % _rate)  + 1;
    }

}