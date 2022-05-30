import {
  InitializableAdminUpgradeabilityProxyFactory, LordArenaTokenDevFactory, LordArenaStakingFactory, LordArenaLpStakingFactory, RandomUtilFactory, LordArenaEquipmentFactory, LordArenaCharacterFactory, GachaBoxFactory, LordArenaMarketFactory, LordaWalletFactory, LordaVestingFactory, LordArenaUpgradeCharacterFactory, LordArenaWalletNftFactory
} from '../types';
import {DRE, getDb} from './misc-utils';
import {eContractid, tEthereumAddress} from './types';

export const getFirstSigner = async () => (await DRE.ethers.getSigners())[0];


export const getProxy = async (address?: tEthereumAddress) =>
  await InitializableAdminUpgradeabilityProxyFactory.connect(
    address ||
      (await getDb().get(`${eContractid.InitializableAdminUpgradeabilityProxy}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getLordArenaTokenDev = async (address?: tEthereumAddress) =>
  await LordArenaTokenDevFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaTokenDev}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getLordArenaStaking = async (address?: tEthereumAddress) =>
  await LordArenaStakingFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaStaking}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getLordArenaLPStaking = async (address?: tEthereumAddress) =>
  await LordArenaLpStakingFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaLPStaking}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getRandomUtil = async (address?: tEthereumAddress) =>
  await RandomUtilFactory.connect(
    address ||
      (await getDb().get(`${eContractid.RandomUtil}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );


export const getLordEquiqment = async (address?: tEthereumAddress) =>
  await LordArenaEquipmentFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaEquipment}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );


export const getLordCharacter = async (address?: tEthereumAddress) =>
  await LordArenaCharacterFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaCharacter}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getGachaBox = async (address?: tEthereumAddress) =>
  await GachaBoxFactory.connect(
    address ||
      (await getDb().get(`${eContractid.GachaBox}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getLordMarket = async (address?: tEthereumAddress) =>
  await LordArenaMarketFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaMarket}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getPrivateLord = async (address?: tEthereumAddress) =>
  await LordaVestingFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LORDAVesting}.${DRE.network.name}`).value()).address,
    await getFirstSigner()
  );

export const getLordWallet = async (address?: tEthereumAddress) =>
  await LordaWalletFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordaWallet}.${DRE.network.name}`).value()).address,
      await getFirstSigner()
  );

export const getLordUpgradeCharacter = async (address?: tEthereumAddress) =>
  await LordArenaUpgradeCharacterFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaUpgradeCharacter}.${DRE.network.name}`).value()).address,
      await getFirstSigner()
  );

export const getLordWalletNFT = async (address?: tEthereumAddress) =>
  await LordArenaWalletNftFactory.connect(
    address ||
      (await getDb().get(`${eContractid.LordArenaWalletNFT}.${DRE.network.name}`).value()).address,
      await getFirstSigner()
  );