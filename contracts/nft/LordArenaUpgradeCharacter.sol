// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../dependencies/open-zeppelin/proxy/utils/Initializable.sol";
import "../dependencies/open-zeppelin/token/ERC20/IERC20Upgradeable.sol";
import "../dependencies/open-zeppelin/access/OwnableUpgradeable.sol";
import "../interfaces/ILordArenaCharacter.sol";

contract LordArenaUpgradeCharacter is Initializable , OwnableUpgradeable{
    
    struct CharacterRequireConfig {
        uint256 characterID;
        uint256 amountRequired;
        uint256[] availableID;
        uint256 quality;
    }

    mapping(uint256 => CharacterRequireConfig) public characterRequire;
    address public lordaCharacter;

    constructor() initializer {}


    function initialize() initializer public {
        __Ownable_init();
    }

    function updateConfig(
        address _lordaCharacter
    ) public onlyOwner {
        lordaCharacter = _lordaCharacter;
    }

    function updateCharacterConfig(CharacterRequireConfig[] memory charInfos) public onlyOwner {
        for (uint256 i = 0; i < charInfos.length; i++){
            characterRequire[charInfos[i].characterID].characterID = charInfos[i].characterID;
            characterRequire[charInfos[i].characterID].amountRequired = charInfos[i].amountRequired;
            characterRequire[charInfos[i].characterID].availableID = charInfos[i].availableID;
            characterRequire[charInfos[i].characterID].quality = charInfos[i].quality;
        }
    }

    function upgradeCharacter(
        uint256 upgradeTokenID, uint256[] memory materialTokenIds
    ) public {
        ILordArenaCharacter.CharacterInfo memory upCharInfo = ILordArenaCharacter(lordaCharacter).properties(upgradeTokenID);
        require(upCharInfo.quality < 10, "This character can not upgrade anymore.");
        require(materialTokenIds.length == characterRequire[upCharInfo.characterID].amountRequired, "Wrong material amount.");
        for (uint256 index = 0; index < materialTokenIds.length; index++) {
            ILordArenaCharacter.CharacterInfo memory maCharInfo = ILordArenaCharacter(lordaCharacter).properties(materialTokenIds[index]);
            bool isValidMaterial = false;
            for (uint256 i = 0; i < characterRequire[upCharInfo.characterID].availableID.length; i++){
                if (maCharInfo.characterID == characterRequire[upCharInfo.characterID].availableID[i]) {
                    isValidMaterial = true;
                    break;
                }
                if (maCharInfo.quality == upCharInfo.quality) {
                    isValidMaterial = true;
                    break;
                }
            }
            require(isValidMaterial, "Material invalid");
            ILordArenaCharacter(lordaCharacter).burn(materialTokenIds[index]);
        }
        ILordArenaCharacter(lordaCharacter).burn(materialTokenIds[upgradeTokenID]);
        ILordArenaCharacter(lordaCharacter).safeMint(msg.sender, upCharInfo.characterID, upCharInfo.quality + 1);
    }

}