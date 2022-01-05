import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getLordCharacter, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
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

    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";

    const contractImpl = await deployMarket(verify);
    // await verifyContract(RandomUtil, "0x4596252b9e5876a48d34A257fF3acEFBD935158B", [])
    // const contractImpl = await getLordCharacter("0x2bDB4030ca6F0ff65659Be7b82B959B13b0160e9");

    // @ts-ignore
    const encodedInitializeStaking = contractImpl.interface.encodeFunctionData('initialize', []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    await proxyContract.deployTransaction.wait();
    // const proxyContract = await getProxy("0x16B23ba46810e3cD818486919941971b335Cf4f4");

    await waitForTx(
        await proxyContract.functions['initialize(address,address,bytes)'](
          contractImpl.address,
          proxyAdmin,
          encodedInitializeStaking
        )
      );

    // const proxyContract = await getProxy("0xC102bEB6add3404b43eA0a87dC002a975d95ffC9");
    // await proxyContract.upgradeTo(contractImpl.address);
  });