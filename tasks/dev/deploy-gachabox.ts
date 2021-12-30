import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { eContractid, eEthereumNetwork } from "../../helpers/types";
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

    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";

    // const contractImpl = await deployGachaBox(verify);
    // await verifyContract(GachaBox, "0x6c3D9CdFBe7C51e9dB5ce18FCF4bDdb7a05ae53b", [])
    const contractImpl = await getGachaBox("0x1E91e8013414283B0387B0bC4046532377D1cBA9");

    // @ts-ignore
    // const encodedInitializeStaking = contractImpl.interface.encodeFunctionData('initialize', []);

    // const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    // await proxyContract.deployTransaction.wait();
    // const proxyContract = await getProxy("0x16B23ba46810e3cD818486919941971b335Cf4f4");

    // await waitForTx(
    //     await proxyContract.functions['initialize(address,address,bytes)'](
    //       contractImpl.address,
    //       proxyAdmin,
    //       encodedInitializeStaking
    //     )
    //   );

    const proxyContract = await getProxy("0x3e3A9Ed909319c7780232Faf8bee7b3A9748Fd08");
    await proxyContract.upgradeTo(contractImpl.address);
  });