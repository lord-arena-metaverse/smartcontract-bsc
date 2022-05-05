import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { AddressConfig, eBBTestAddress, eBSCAddress, eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getLordWallet, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import { deployGachaBox, deployInitializableAdminUpgradeabilityProxy, deployLordaWallet, deployRandom } from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordaWallet } = eContractid;

task(`deploy-${LordaWallet}`, `Deploys the ${LordaWallet} contract`)
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


    const contractImpl = await deployLordaWallet(verify);

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

    console.log(`\tFinished ${LordaWallet} deployment`);
    // const proxyContract = await getProxy("0xC102bEB6add3404b43eA0a87dC002a975d95ffC9");
    // await proxyContract.upgradeTo(contractImpl.address);
  });


  task(`config-${LordaWallet}`, `Deploys the ${LordaWallet} contract`)
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


    const contract = await getLordWallet(globalAddress.LordaWallet);

    console.log(`\t\t Update Config Hash : ${(await contract.updateConfig(globalAddress.LORDADToken, globalAddress.Treasury)).hash} `);  

    console.log(`\tFinished ${LordaWallet} deployment`);
  });


task(`view-${LordaWallet}`, `Deploys the ${LordaWallet} contract`)
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


    const contract = await getRandomUtil(globalAddress.RandomUtil);
  });