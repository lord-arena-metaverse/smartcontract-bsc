export enum eEthereumNetwork {
  buidlerevm = "buidlerevm",
  kovan = "kovan",
  ropsten = "ropsten",
  main = "main",
  coverage = "coverage",
  hardhat = "hardhat",
  bbtest = "bbtest",
  bsc = "bsc",
}

export enum EthereumNetworkNames {
  kovan = "kovan",
  ropsten = "ropsten",
  main = "main",
}

export enum AavePools {
  proto = "proto",
  secondary = "secondary",
}

export enum eContractid {
  LordArenaTokenDev = "LordArenaTokenDev",
  LordArenaStaking = "LordArenaStaking",
  LordArenaLPStaking = "LordArenaLPStaking",
  GachaBox = "GachaBox",
  LordArenaCharacter = "LordArenaCharacter",
  LordArenaEquipment = "LordArenaEquipment",
  RandomUtil = "RandomUtil",
  LORDAVesting = 'LORDAVesting',
  LordArenaMarket = "LordArenaMarket",
  LordaWallet = "LordaWallet",
  TransparentUpgradeableProxy = "TransparentUpgradeableProxy",
  InitializableAdminUpgradeabilityProxy = "InitializableAdminUpgradeabilityProxy",
  LordArenaClaimTokenDev = "LordArenaClaimTokenDev",
  LordArenaWallet = "LordArenaWallet",
  LordArenaUpgradeCharacter = "LordArenaUpgradeCharacter",
  LordArenaWalletNFT = "LordArenaWalletNFT",
  LordaDToken = "LordaDToken"
}

export type tEthereumAddress = string;


export interface AddressConfig {
  LORDAToken: string;
  LORDADToken: string;
  ProxyAdmin: string;
  Treasury: string;
  GachaBox: string;
  LordArenaCharacter: string;
  LordArenaEquipment: string;
  RandomUtil: string;
  LordArenaMarket: string;
  LordaWallet: string;
  LordaUpgradeCharacter: string;
  LordArenaWalletNFT: string;
}

export let eBBTestAddress: AddressConfig = {
  LORDAToken: "0x6503E34432D3BA7F80f10D04e3fD4450573519B4",
  LORDADToken: "0x822680f7625494E09eB6591B27cbfED60e3469E8",
  ProxyAdmin: "0x48C5E5002Cf98170355e72d649929c46398fA42E",
  Treasury: "0xa8FfDFfAb400dafe5c5958e036Be40016484ad0c",
  GachaBox: "0x72d2AfBF777DF521ca4585428388E8853c31DAE3",
  LordArenaCharacter: "0x3cCacfbd1486EDD4Ee59c4ad868399C74d6F8B45",
  LordArenaEquipment: "0x329021Eb1820BfF8Ad494db75f641b88956dEA4f",
  RandomUtil: "0x28b77e4D781E5D6684c907F677B701A73b330696",
  LordArenaMarket: "0xe7e5C5325426556D4c3F448E5928B05D96Bec0fE",
  LordaWallet: "0xBA464a42A962545232892CE6fe8bB2646dBf29B9",
  LordaUpgradeCharacter: "",
  LordArenaWalletNFT: "0xFC8dDc0D7f914A537E241Ce03BE234ac574bACD5"
};

export let eBSCAddress: AddressConfig = {
  LORDAToken: "0xc326622FcA914CA15fD44DD070232cE3cd358Dde",
  LORDADToken: "0x52F7714cE51Fe271606c1caFE5E1F4722421BE8a",
  GachaBox: "0x937C06D619bf9367Bc18f6E8D446105Ef2879B84",
  ProxyAdmin: "0x683b99Fcd0a8cc0d10718Bb1a85B3b78345065b8",
  Treasury: "0x359269513a2e76b4153F8f181eA1A7fc9655fA50",
  LordArenaCharacter: "0x8fFaddFc3A0C00D989E1dFbaABfcb05D27AFc683",
  LordArenaEquipment: "0x765bC67f4d3f9823B4b466ee9a95436C10BF4f9b",
  RandomUtil: "0x19c980340B7C7b33B12Aced54d50Cdb9A3ceBFce",
  LordArenaMarket: "0xEd4ED769a627f0ba34a8cEbcd655c2eD77F021dd",
  LordaWallet: "0x10BcD72b06240C2A8dF23b7587E898cF4Be06f93",
  LordaUpgradeCharacter: "",
  LordArenaWalletNFT: "0x5c4AbAd7825Bef0D2917E585aC86E1399e0FE923"
};
