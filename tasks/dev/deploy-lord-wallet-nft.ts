import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { AddressConfig, eBBTestAddress, eBSCAddress, eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getLordCharacter, getLordMarket, getLordUpgradeCharacter, getLordWalletNFT, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import { deployGachaBox, deployInitializableAdminUpgradeabilityProxy, deployLordArenaUpgradeCharacter, deployLordArenaWalletNFT, deployLordCharacter, deployMarket } from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaWalletNFT } = eContractid;

task(`deploy-${LordArenaWalletNFT}`, `Deploys the ${LordArenaWalletNFT} contract`)
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

    const contractImpl = await deployLordArenaWalletNFT(verify);

    // @ts-ignore
    const encodedInitializeStaking = contractImpl.interface.encodeFunctionData('initialize', []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    await proxyContract.deployTransaction.wait();

    await waitForTx(
        await proxyContract.functions['initialize(address,address,bytes)'](
          contractImpl.address,
          globalAddress.ProxyAdmin,
          encodedInitializeStaking
        )
      );

    // const proxyContract = await getProxy(globalAddress.LordArenaWalletNFT);
    // await proxyContract.upgradeTo("0x06Ffe76A057cf0fecDaa0A2585484C513572E977");
  });


task(`config-${LordArenaWalletNFT}`, `Deploys the ${LordArenaWalletNFT} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    let whitelist : any[] = [];
    let globalAddress : AddressConfig = eBBTestAddress;
    if (network == eEthereumNetwork.bbtest) {
      globalAddress = eBBTestAddress;
      whitelist = [
        globalAddress.Treasury
      ]
    }
    else if (network == eEthereumNetwork.bsc) {
      globalAddress = eBSCAddress;
      whitelist = [
        
      ]
    }

    const contract = await getLordWalletNFT(globalAddress.LordArenaWalletNFT);

    // Set NFT Address
    console.log(`\t\t Update config NFT Address : ${(await contract.updateConfig(globalAddress.LordArenaCharacter, globalAddress.LordArenaEquipment)).hash} `);  
    
    // Set Whitelist Withdraw
    for (let index = 0; index < whitelist.length; index++) {
      const element = whitelist[index];
      console.log(`\t\t Add whitelist : ${(await contract.updateWhitelistWithdraw(element, true)).hash} `);  
    }
  });
