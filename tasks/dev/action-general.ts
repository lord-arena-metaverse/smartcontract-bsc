import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { AddressConfig, eBBTestAddress, eBSCAddress, eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getLordCharacter, getLordWalletNFT, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import { deployGachaBox, deployInitializableAdminUpgradeabilityProxy, deployLordCharacter } from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaCharacter } = eContractid;

task(`action-general`, `Deploys the ${LordArenaCharacter} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    
    let globalAddress : AddressConfig = eBBTestAddress;
    if (network == eEthereumNetwork.bbtest) {
      globalAddress = eBBTestAddress;
    }
    else if (network == eEthereumNetwork.bsc) {
      globalAddress = eBSCAddress;
    }

    const charContract = await getLordCharacter(globalAddress.LordArenaCharacter);
    const equiqmentContract = await getLordCharacter(globalAddress.LordArenaEquipment);
    const walletNFTContract = await getLordWalletNFT(globalAddress.LordArenaWalletNFT);

    const sender = "0xFCDE74D621f65aDDc2532A3cF1B79ebA8D63bE47"
    // Approve the character
    // console.log(`\t\t Update config NFT Address : ${(await equiqmentContract.setApprovalForAll(globalAddress.LordArenaWalletNFT, true)).hash} `);  

    // Deposit the character
    console.log(`\t\t Deposit : ${(await walletNFTContract.deposit([3320,3319,3318], globalAddress.LordArenaCharacter)).hash} `);  

    // withdraw the character
    // console.log(`\t\t Withdraw : ${(await walletNFTContract.withdraw([3323], globalAddress.LordArenaEquipment, sender)).hash} `);  
  });
