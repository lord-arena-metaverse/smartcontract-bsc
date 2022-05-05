import { task } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import { eContractid, eEthereumNetwork } from "../../helpers/types";
import { getContract, registerContractInJsonDb } from "../../helpers/contracts-helpers";
import { getGachaBox, getProxy, getRandomUtil } from "../../helpers/contracts-getters";
import {
  deployGachaBox,
  deployInitializableAdminUpgradeabilityProxy,
  deployLordArenaClaimTokenDev,
  deployLordArenaWallet,
} from "../../helpers/contracts-deployments";

import { waitForTx } from "../../helpers/misc-utils";
import { verifyContract } from "../../helpers/etherscan-verification";

const { LordArenaClaimTokenDev, LordArenaWallet } = eContractid;

task(`deploy-${LordArenaClaimTokenDev}`, `Deploys the ${LordArenaClaimTokenDev} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const contractImpl = await deployLordArenaClaimTokenDev(verify);
    console.log(`\tFinished ${LordArenaClaimTokenDev} deployment`);
  });

task(`deploy-wallet-first`, `Deploys the ${LordArenaWallet} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";

    const contractImpl = await deployLordArenaWallet(verify);

    // @ts-ignore
    const encodedInitializeStaking = contractImpl.interface.encodeFunctionData("initialize", []);

    const proxyContract = await deployInitializableAdminUpgradeabilityProxy();
    await proxyContract.deployTransaction.wait();

    await waitForTx(
      await proxyContract.functions["initialize(address,address,bytes)"](
        contractImpl.address,
        proxyAdmin,
        encodedInitializeStaking
      )
    );

    console.log("first deploy: ", contractImpl.address, proxyContract.address);
  });

task(`upgrade-wallet-1`, `Deploys the ${LordArenaWallet} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    const proxyAdmin = "0xA053199b45dC7b1f2c666Ad579568D2e27238e44";
    // const contractImpl = await deployGachaBox(verify);
    const proxyContract = await getProxy("0x4428Ff660576D7a631dF3d704DD345239D9261Ba"); // get address from deploy-gachabox-first
    // await proxyContract.upgradeTo(contractImpl.address);
    await proxyContract.upgradeTo("0x96bA741fbD0D149E7133848Fd9F167d511c3bf16");
    // console.log(`upgraded to  ${contractImpl.address}, via proxy  ${proxyContract.address}`);
    console.log(`upgraded to  0x96bA741fbD0D149E7133848Fd9F167d511c3bf16, via proxy  ${proxyContract.address}`);
  });

task(`upgrade-wallet`, `Deploys the ${LordArenaWallet} contract`)
  .addFlag("verify", "Verify Lord Arena contract via Etherscan API.")
  .setAction(async ({ verify, vaultAddress, aaveAddress }, localBRE) => {
    await localBRE.run("set-DRE");

    if (!localBRE.network.config.chainId) {
      throw new Error("INVALID_CHAIN_ID");
    }

    const network = localBRE.network.name as eEthereumNetwork;
    const contractImpl = await getGachaBox("0x96bA741fbD0D149E7133848Fd9F167d511c3bf16");
    const proxyContract = await getProxy("0x3e3A9Ed909319c7780232Faf8bee7b3A9748Fd08"); // get address from deploy-gachabox-first
    await proxyContract.upgradeTo(contractImpl.address);
    console.log(`upgraded to  ${contractImpl.address}, via proxy  ${proxyContract.address}`);
  });
