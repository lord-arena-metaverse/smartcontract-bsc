import { tEthereumAddress, eContractid } from "./types";
import { getFirstSigner } from "./contracts-getters";
import {
  InitializableAdminUpgradeabilityProxyFactory,
  LordArenaLpStakingFactory,
  LordArenaStakingFactory,
  LordArenaTokenDevFactory,
  GachaBoxFactory,
} from "../types";
import { withSaveAndVerify } from "./contracts-helpers";
import { waitForTx } from "./misc-utils";
import { Interface } from "ethers/lib/utils";

export const deployInitializableAdminUpgradeabilityProxy = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new InitializableAdminUpgradeabilityProxyFactory(await getFirstSigner()).deploy(...args),
    eContractid.InitializableAdminUpgradeabilityProxy,
    args,
    verify
  );
};

export const deployLordArenaTokenDev = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaTokenDevFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaTokenDev,
    args,
    verify
  );
};

export const deployLordArenaStaking = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaStakingFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaStaking,
    args,
    verify
  );
};

export const deployLordArenaLPStaking = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaLpStakingFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaLPStaking,
    args,
    verify
  );
};

export const deployGachaBox = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new GachaBoxFactory(await getFirstSigner()).deploy(...args),
    eContractid.GachaBox,
    args,
    verify
  );
};
