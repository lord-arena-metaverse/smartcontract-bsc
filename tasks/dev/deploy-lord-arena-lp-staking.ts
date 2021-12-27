import { task } from 'hardhat/config';

import { eContractid, eEthereumNetwork } from '../../helpers/types';

import { getContract, registerContractInJsonDb } from '../../helpers/contracts-helpers';
import { getLordArenaLPStaking, getProxy } from '../../helpers/contracts-getters';
import '@openzeppelin/hardhat-upgrades';
import { deployInitializableAdminUpgradeabilityProxy, deployLordArenaLPStaking, deployLordArenaStaking} from '../../helpers/contracts-deployments';

import { waitForTx } from '../../helpers/misc-utils';
import { verifyContract } from '../../helpers/etherscan-verification';

const {LordArenaLPStaking } = eContractid;

task(`deploy-${LordArenaLPStaking}`, `Deploys the ${LordArenaLPStaking} contract`)
  .addFlag('verify', 'Verify Lastsurvivor contract via Etherscan API.')
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run('set-DRE');

    if (!localBRE.network.config.chainId) {
      throw new Error('INVALID_CHAIN_ID');
    }
    
    const network = localBRE.network.name as eEthereumNetwork;

    const proxyAdmin = "0x683b99Fcd0a8cc0d10718Bb1a85B3b78345065b8"

    // const implContract = await deployLordArenaLPStaking(verify);
    // await verifyContract(AntiBot, "0x4596252b9e5876a48d34A257fF3acEFBD935158B", [])
    const implContract = await getLordArenaLPStaking("0x38aF6f328d187d2d58cD8eB4F2D3214112139D3f");

    // @ts-ignore
    const encodedInitializeContract = implContract.interface.encodeFunctionData('initialize', []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    await proxyContract.deployTransaction.wait();
    // const proxyContract = await getProxy("0xBdb7B04A204ca4864B79198A5ef3e22217d01951");
    
    
    await waitForTx(
        await proxyContract.functions['initialize(address,address,bytes)'](
          implContract.address,
          proxyAdmin,
          encodedInitializeContract
        )
      );

    // const proxyContract = await getProxy("0x1c1fa59D27c8abe1f27301a4a96CC6DD65772755");
    // await proxyContract.upgradeTo(implContract.address)

    console.log(`\tFinished ${LordArenaLPStaking} deployment`);
  });
