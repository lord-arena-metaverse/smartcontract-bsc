import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getProxy } from "../../helpers/contracts-getters";
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
    const lordArenaTokenDevImpl = await deployGachaBox(verify);

    console.log(`\tFinished ${GachaBox} deployment`);
  });

task(`upgrade-${GachaBox}`, `Upgrades the ${GachaBox} contract`)
  .addFlag("verify", `Verify ${GachaBox} contract via Etherscan API.`)
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    // const network = localBRE.network.name as eEthereumNetwork;
    // const proxyAdmin = process.env.PROXY_PRIVATE_KEY || "";
    // const implContract = await deployGachaBox(verify);
    // const encodedInitializeImpl = implContract.interface.encodeFunctionData("initialize", []);
    // const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    // await proxyContract.deployTransaction.wait();

    // await waitForTx(
    //   await proxyContract.functions["initialize(address,address,bytes)"](
    //     implContract.address,
    //     proxyAdmin,
    //     encodedInitializeImpl
    //   )
    // );

    console.log(`\tFinished ${GachaBox} deployment`);
  });
