import { tEthereumAddress, eContractid } from "./types";
import { getFirstSigner } from "./contracts-getters";
import {
  InitializableAdminUpgradeabilityProxyFactory,
  LordArenaLpStakingFactory,
  LordArenaStakingFactory,
  LordArenaTokenDevFactory,
  GachaBoxFactory,
  LordArenaCharacterFactory,
  LordArenaEquipmentFactory,
  RandomUtilFactory,
  LordArenaMarketFactory,
  LordaWalletFactory,
  LordArenaWalletFactory,
  LordArenaClaimTokenDevFactory,
  LordArenaUpgradeCharacterFactory,
  LordArenaWalletNftFactory
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

export const deployLordCharacter = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaCharacterFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaCharacter,
    args,
    verify
  );
};

export const deployLordEquipment = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaEquipmentFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaEquipment,
    args,
    verify
  );
};

export const deployRandom = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new RandomUtilFactory(await getFirstSigner()).deploy(...args),
    eContractid.RandomUtil,
    args,
    verify
  );
};

export const deployMarket = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaMarketFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaMarket,
    args,
    verify
  );
};

export const deployLordArenaClaimTokenDev = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaClaimTokenDevFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaClaimTokenDev,
    args,
    verify
  );
};

export const deployLordArenaWallet = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaWalletFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaWallet,
    args,
    verify
  );
};

export const deployLordArenaUpgradeCharacter = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaUpgradeCharacterFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaUpgradeCharacter,
    args,
    verify
  );
};

export const deployLordArenaWalletNFT = async (verify?: boolean) => {
  const args: [] = [];
  return withSaveAndVerify(
    await new LordArenaWalletNftFactory(await getFirstSigner()).deploy(...args),
    eContractid.LordArenaWalletNFT,
    args,
    verify
  );
};
