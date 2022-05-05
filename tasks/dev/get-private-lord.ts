import { task } from 'hardhat/config';

import { eContractid, eEthereumNetwork } from '../../helpers/types';

import { getContract, registerContractInJsonDb } from '../../helpers/contracts-helpers';
import { getPrivateLord, getProxy } from '../../helpers/contracts-getters';
import '@openzeppelin/hardhat-upgrades';

import { waitForTx } from '../../helpers/misc-utils';
import { verifyContract } from '../../helpers/etherscan-verification';

const { LORDAVesting} = eContractid;

task(`deploy-${LORDAVesting}`, `Deploys the ${LORDAVesting} contract`)
  .addFlag('verify', 'Verify contract via Etherscan API.')
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run('set-DRE');

    if (!localBRE.network.config.chainId) {
      throw new Error('INVALID_CHAIN_ID');
    }
    
    const network = localBRE.network.name as eEthereumNetwork;

    const privateLord = await getPrivateLord("0x66CF871d12b4AcF298085eEf9086f8fd5438f8B7");

    // await privateLord.transferOwnership("0xA83C1d7E512fe5Ec0304E076E41b255c5133BE73");
    console.log(`\t check claim ${await privateLord.infoWallet("0xCfFdf9dEB3ce0e0d19A721AE59E2aAA92458bBb0")}`);
    
    console.log(`\tFinished ${LORDAVesting} deployment`);
  });
