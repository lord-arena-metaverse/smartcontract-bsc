import {
  InitializableAdminUpgradeabilityProxyFactory, LordArenaTokenDevFactory, LordArenaStakingFactory, LordArenaLpStakingFactory
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
