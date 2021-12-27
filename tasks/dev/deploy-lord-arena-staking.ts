import { task } from "hardhat/config";

import { eContractid, eEthereumNetwork } from "../../helpers/types";

import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getProxy } from "../../helpers/contracts-getters";
import "@openzeppelin/hardhat-upgrades";
import {
  deployInitializableAdminUpgradeabilityProxy,
  deployLordArenaStaking,
} from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaStaking } = eContractid;

task(`deploy-${LordArenaStaking}`, `Deploys the ${LordArenaStaking} contract`)
  .addFlag("verify", "Verify LordArena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;

    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";

    const lordArenaStakingImpl = await deployLordArenaStaking(verify);
    // await verifyContract(AntiBot, "0x4596252b9e5876a48d34A257fF3acEFBD935158B", [])
    // const antiBotImpl = await getAntiBot("0x53B35Fd1DDaeEd69ba12CB56701e550Ea1b709e0");

    // @ts-ignore
    // const encodedInitializeStaking = lordArenaStakingImpl.interface.encodeFunctionData('initialize', []);

    // const LordArenaProxy = await deployInitializableAdminUpgradeabilityProxy(verify);
    // await LordArenaProxy.deployTransaction.wait();
    // const antiBotProxy = await getProxy("0x16B23ba46810e3cD818486919941971b335Cf4f4");

    // await waitForTx(
    //     await LordArenaProxy.functions['initialize(address,address,bytes)'](
    //       lordArenaStakingImpl.address,
    //       proxyAdmin,
    //       encodedInitializeStaking
    //     )
    //   );

    const lordArenaStakingProxy = await getProxy("0xC102bEB6add3404b43eA0a87dC002a975d95ffC9");
    await lordArenaStakingProxy.upgradeTo(lordArenaStakingImpl.address);

    console.log(`\tFinished ${LordArenaStaking} deployment`);
  });
