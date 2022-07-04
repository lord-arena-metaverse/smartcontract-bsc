import { task } from "hardhat/config";

import { eContractid, eEthereumNetwork } from "../../helpers/types";

import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getProxy } from "../../helpers/contracts-getters";
import "@openzeppelin/hardhat-upgrades";
import {
  deployInitializableAdminUpgradeabilityProxy,
  deployLordaDToken,
  deployLordArenaTokenDev,
} from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordaDToken } = eContractid;

task(`deploy-${LordaDToken}`, `Deploys the ${LordaDToken} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;

    const lordArenaTokenDevImpl = await deployLordaDToken(true);

    console.log(`\tFinished ${LordaDToken} deployment`);
  });
