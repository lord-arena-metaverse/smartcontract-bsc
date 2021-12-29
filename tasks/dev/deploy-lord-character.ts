import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";

import { eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getProxy } from "../../helpers/contracts-getters";
import { deployInitializableAdminUpgradeabilityProxy, deployLordCharacter } from "../../helpers/contracts-deployments";
import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaCharacter } = eContractid;

task(`deploy-${LordArenaCharacter}`, `Deploys the ${LordArenaCharacter} contract`)
  .addFlag("verify", `Verify ${LordArenaCharacter} contract via Etherscan API.`)
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";
    const contractImpl = await deployLordCharacter(verify);

    // @ts-ignore
    const encodedInitialize = contractImpl.interface.encodeFunctionData("initialize", []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy(verify);
    await proxyContract.deployTransaction.wait();

    await waitForTx(
      await proxyContract.functions["initialize(address,address,bytes)"](
        contractImpl.address,
        proxyAdmin,
        encodedInitialize
      )
    );

    console.log(`\tFinished ${LordArenaCharacter} deployment`);
  });
