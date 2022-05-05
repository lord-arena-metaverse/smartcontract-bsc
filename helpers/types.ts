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
  LordArenaMarket = "LordArenaMarket",
  LordaWallet = "LordaWallet",
  TransparentUpgradeableProxy = "TransparentUpgradeableProxy",
  InitializableAdminUpgradeabilityProxy = "InitializableAdminUpgradeabilityProxy",
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
  LordaWallet: "0xBA464a42A962545232892CE6fe8bB2646dBf29B9"
};

export let eBSCAddress: AddressConfig = {
  LORDAToken: "",
  LORDADToken: "",
  GachaBox: "",
  ProxyAdmin: "",
  Treasury: "",
  LordArenaCharacter: "",
  LordArenaEquipment: "",
  RandomUtil: "",
  LordArenaMarket: "",
  LordaWallet: ""
};
