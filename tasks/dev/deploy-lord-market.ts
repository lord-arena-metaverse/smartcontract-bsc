import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { AddressConfig, eBBTestAddress, eBSCAddress, eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getLordCharacter, getLordMarket, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import { deployGachaBox, deployInitializableAdminUpgradeabilityProxy, deployLordCharacter, deployMarket } from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaMarket } = eContractid;

task(`deploy-${LordArenaMarket}`, `Deploys the ${LordArenaMarket} contract`)
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

    const contractImpl = await deployMarket(verify);

    // @ts-ignore
    const encodedInitializeStaking = contractImpl.interface.encodeFunctionData('initialize', []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    await proxyContract.deployTransaction.wait();
    // const proxyContract = await getProxy("0x16B23ba46810e3cD818486919941971b335Cf4f4");

    await waitForTx(
        await proxyContract.functions['initialize(address,address,bytes)'](
          contractImpl.address,
          globalAddress.ProxyAdmin,
          encodedInitializeStaking
        )
      );

    // const proxyContract = await getProxy("0xC102bEB6add3404b43eA0a87dC002a975d95ffC9");
    // await proxyContract.upgradeTo(contractImpl.address);
  });


task(`config-${LordArenaMarket}`, `Deploys the ${LordArenaMarket} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    
    let globalAddress : AddressConfig = eBBTestAddress;
    let whiteListMinter: any[] = [];
    if (network == eEthereumNetwork.bbtest) {
      globalAddress = eBBTestAddress;
      whiteListMinter = [
        [globalAddress.GachaBox, true, "GachaBox"],
      ]
    }
    else if (network == eEthereumNetwork.bsc) {
      globalAddress = eBSCAddress;
    }

    const contract = await getLordMarket(globalAddress.LordArenaMarket);

    // Set Treasurry
    console.log(`\t\t Update Treasury Hash : ${(await contract.updateConfig(globalAddress.Treasury)).hash} `);  
    console.log(`\t\t Update Currency Fee Hash : ${(await contract.updateCurrencyFee("50", globalAddress.LORDAToken)).hash} `);  
    console.log(`\t\t Update Currency Token Hash : ${(await contract.updateCurrencyToken(globalAddress.LORDAToken, true)).hash} `);  
    console.log(`\t\t Update Character Hash : ${(await contract.updateNFTToken(globalAddress.LordArenaCharacter, true)).hash} `);  
    console.log(`\t\t Update Equiqment Hash : ${(await contract.updateNFTToken(globalAddress.LordArenaEquipment, true)).hash} `);  
    
  });