import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { AddressConfig, eBBTestAddress, eBSCAddress, eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getGachaBox, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import { deployGachaBox, deployInitializableAdminUpgradeabilityProxy } from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { GachaBox } = eContractid;

task(`deploy-${GachaBox}`, `Deploys the ${GachaBox} contract`)
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

    const contractImpl = await deployGachaBox(verify);

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

    // const proxyContract = await getProxy("0x937C06D619bf9367Bc18f6E8D446105Ef2879B84");
    // await proxyContract.upgradeTo(contractImpl.address);
  });


task(`config-${GachaBox}`, `Deploys the ${GachaBox} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    
    let globalAddress : AddressConfig = eBBTestAddress;
    let boxConfig: any[] = [];
    if (network == eEthereumNetwork.bbtest) {
      globalAddress = eBBTestAddress;
    }
    else if (network == eEthereumNetwork.bsc) {
      globalAddress = eBSCAddress;
    }
    boxConfig = [
      [
        "7200",
        "20000000000000000000000",
        "1",
        "7200",
        globalAddress.LORDAToken
      ],
      [
        "800",
        "150000000000000000000",
        "2",
        "800",
        globalAddress.LORDAToken
      ]
    ]
    const contract = await getGachaBox(globalAddress.GachaBox);

    // Set Treasurry
    console.log(`\t\t Update Config Hash : ${(await contract.updateConfig(globalAddress.LordArenaCharacter, globalAddress.LordArenaEquipment, globalAddress.Treasury, globalAddress.RandomUtil)).hash} `);  
    for (let index = 0; index < boxConfig.length; index++) {
      const element = boxConfig[index];
      console.log(`\t\t Update Box ${element[2]} Hash : ${(await contract.updateBoxConfig(element[0], element[1], element[2], element[3], element[4])).hash} `);  
    }
  });
