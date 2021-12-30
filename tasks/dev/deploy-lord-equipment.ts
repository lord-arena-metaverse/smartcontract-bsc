import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";

import { eContractid, eEthereumNetwork } from "../../helpers/types";
import { waitForTx } from "../../helpers/misc-utils";
import { deployInitializableAdminUpgradeabilityProxy, deployLordEquipment } from "../../helpers/contracts-deployments";

const { LordArenaEquipment } = eContractid;

task(`deploy1-${LordArenaEquipment}`, `Deploys the ${LordArenaEquipment} contract`)
  .addFlag("verify", `Verify ${LordArenaEquipment} contract via Etherscan API.`)
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";
    const contractImpl = await deployLordEquipment(verify);

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

    console.log(`\tFinished ${LordArenaEquipment} deployment`);
  });
