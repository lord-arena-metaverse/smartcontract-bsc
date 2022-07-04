// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/token/ERC721/IERC721Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";


contract LordArenaWalletNFT is Initializable, OwnableUpgradeable {
  constructor() initializer {}

  struct DepositInfo {
        address senderCharacter;
        address nftChacter;
        uint256 charDepositAt;
        uint256 charWithdrawAt;
        address senderEquiqment;
        address nftEquiqment;
        uint256 equiqmentDepositAt;
        uint256 equiqmentWithdrawAt;
    }

  mapping(uint256 => DepositInfo) public tokenDeposit;
  mapping(address => bool) public whitelistWithdraw;
  address public CHARACTER_ADDRESS;
  address public EQUIQMENT_ADDRESS;

  event DepositNFTEvent(address indexed sender, address nftAddress, uint256 tokenID, uint256 depositAt);
  event WithdrawNFTEvent(address indexed sender, address nftAddress, uint256 tokenID, uint256 withdrawAt);

  function initialize() public initializer {
    __Ownable_init();
  }

  modifier onlyNonContract {
    require(tx.origin == msg.sender, "Only non-contract call.");
    _;
  }

  modifier onlyWhitelist() {
    require(whitelistWithdraw[msg.sender], "Invalid Whitelist");
    _;
  }

  // Update config
  function updateConfig(address _charAddress, address _equiqmentAddress) public onlyOwner {
    CHARACTER_ADDRESS = _charAddress;
    EQUIQMENT_ADDRESS = _equiqmentAddress;
  }

  // Update config
  function updateWhitelistWithdraw(address _whitelist, bool _status) public onlyOwner {
    whitelistWithdraw[_whitelist] = _status;
  }

  function deposit(uint256[] memory _tokenIDs, address _nftAddress) public onlyNonContract {
    require(_nftAddress == CHARACTER_ADDRESS || _nftAddress == EQUIQMENT_ADDRESS, "Invalid nft.");
    for (uint256 index = 0; index < _tokenIDs.length; index++) {
      
      IERC721Upgradeable(_nftAddress).transferFrom(msg.sender, address(this), _tokenIDs[index]);
      if (_nftAddress == CHARACTER_ADDRESS) {
        tokenDeposit[_tokenIDs[index]].senderCharacter = msg.sender;
        tokenDeposit[_tokenIDs[index]].nftChacter = _nftAddress;
        tokenDeposit[_tokenIDs[index]].charDepositAt = block.timestamp;
        tokenDeposit[_tokenIDs[index]].charWithdrawAt = 0;
      }
      else {
        tokenDeposit[_tokenIDs[index]].senderEquiqment = msg.sender;
        tokenDeposit[_tokenIDs[index]].nftEquiqment = _nftAddress;
        tokenDeposit[_tokenIDs[index]].charDepositAt = block.timestamp;
        tokenDeposit[_tokenIDs[index]].charWithdrawAt = 0;
      }
      emit DepositNFTEvent(msg.sender, _nftAddress, _tokenIDs[index], block.timestamp);
    }
    
  }

  function withdraw(uint256[] memory _tokenIDs, address _nftAddress, address receiver) public onlyNonContract onlyWhitelist {
    require(_nftAddress == CHARACTER_ADDRESS || _nftAddress == EQUIQMENT_ADDRESS, "Invalid nft.");
    for (uint256 index = 0; index < _tokenIDs.length; index++) {
      if (_nftAddress == CHARACTER_ADDRESS) {
        require(receiver == tokenDeposit[_tokenIDs[index]].senderCharacter, "Invalid nft owner.");
        IERC721Upgradeable(_nftAddress).transferFrom(address(this), receiver, _tokenIDs[index]);
        tokenDeposit[_tokenIDs[index]].senderCharacter = address(0);
        tokenDeposit[_tokenIDs[index]].nftChacter = address(0);
        tokenDeposit[_tokenIDs[index]].charDepositAt = 0;
        tokenDeposit[_tokenIDs[index]].charWithdrawAt = block.timestamp;
      }
      else {
        require(receiver == tokenDeposit[_tokenIDs[index]].senderEquiqment, "Invalid nft owner.");
        IERC721Upgradeable(_nftAddress).transferFrom(address(this), receiver, _tokenIDs[index]);
        tokenDeposit[_tokenIDs[index]].senderEquiqment = address(0);
        tokenDeposit[_tokenIDs[index]].nftEquiqment = address(0);
        tokenDeposit[_tokenIDs[index]].charDepositAt = 0;
        tokenDeposit[_tokenIDs[index]].charWithdrawAt = block.timestamp;
        emit WithdrawNFTEvent(receiver, _nftAddress, _tokenIDs[index], block.timestamp);  
      }      
    }
  }
}
