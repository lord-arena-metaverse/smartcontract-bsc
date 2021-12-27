import { task } from "hardhat/config";

import { eContractid, eEthereumNetwork } from "../../helpers/types";

import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getProxy } from "../../helpers/contracts-getters";
import "@openzeppelin/hardhat-upgrades";
import {
  deployInitializableAdminUpgradeabilityProxy,
  deployLordArenaTokenDev,
} from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaTokenDev } = eContractid;

task(`deploy-${LordArenaTokenDev}`, `Deploys the ${LordArenaTokenDev} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;

    const lordArenaTokenDevImpl = await deployLordArenaTokenDev(verify);

    console.log(`\tFinished ${LordArenaTokenDev} deployment`);
  });
