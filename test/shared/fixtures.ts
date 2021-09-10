import { Contract, Wallet } from "ethers";
import { artifacts, ethers } from "hardhat"
import { Tokens, UniswapAddresses } from "./mockInfo";

let storage:Contract 
let punkMock:Contract 

export async function unitPunkMockFixtures([,,,,,owner] : Wallet[]): Promise<Contract> {
    const Punk = await ethers.getContractFactory("PunkMock");
    const punk = await Punk.deploy(owner.address)
    await punk.deployed();
    punkMock = punk;
    return punk;
}

export async function unitFixtureForge(): Promise<Contract> {
    const Forge = await ethers.getContractFactory("Forge");
    const forge = await Forge.deploy()
    await forge.deployed();
    return forge;
}

export async function unitFixtureForge2nd(): Promise<Contract> {
    const Forge = await ethers.getContractFactory("Forge");
    const forge = await Forge.deploy()
    await forge.deployed();
    return forge;
}

export async function unitFixtureForge3rd(): Promise<Contract> {
    const Forge = await ethers.getContractFactory("Forge");
    const forge = await Forge.deploy()
    await forge.deployed();
    return forge;
}

export async function unitFixtureVariables([,,,,,owner] : Wallet[]): Promise<Contract> {
    const Variables = await ethers.getContractFactory("Variables")
    const variables = await Variables.connect(owner).deploy()
    await variables.deployed()

    return variables
}

export async function unitFixtureCompoundModel(): Promise<Contract> {
    const CompoundModel = await ethers.getContractFactory("CompoundModel")
    const compoundModel = await CompoundModel.deploy()
    await compoundModel.deployed()
    return compoundModel
}

export async function unitFixtureUniswapV2(): Promise<Contract> {
    const IUniswapV2Router = await artifacts.readArtifact("IUniswapV2Router");
    const uniswapRouter = await ethers.getContractAt(IUniswapV2Router.abi, UniswapAddresses.UniswapV2Router02);
    return uniswapRouter
}

export async function unitFixtureDaiToken(): Promise<Contract> {
    const IDaiToken = await artifacts.readArtifact("IERC20")
    const daiToken = await ethers.getContractAt(IDaiToken.abi, Tokens.Dai)
    return daiToken
}

export async function unitFixtureRecoveryFund([,,,,,owner] : Wallet[]): Promise<Contract> {
    const RecoveryFundMock = await ethers.getContractFactory("RecoveryFund")
    const recoveryFundMock = await RecoveryFundMock.connect(owner).deploy()
    return recoveryFundMock
}

export async function unitFixtureOwnableStorage([,,,,,owner] : Wallet[]): Promise<Contract> {
    const OwnableStorage = await ethers.getContractFactory("OwnableStorage")
    const ownableStorage = await OwnableStorage.connect(owner).deploy()
    await ownableStorage.deployed()
    storage = ownableStorage;
    return ownableStorage
}

export async function unitFixtureTreasury(): Promise<Contract> {
    const Treasury = await ethers.getContractFactory("Treasury")
    const treasury = await Treasury.deploy()
    await treasury.deployed()
    return treasury;
}

export async function unitFixtureOpTreasury(): Promise<Contract> {
    const OpTreasury = await ethers.getContractFactory("OperatorTreasury")
    const opTreasury = await OpTreasury.deploy(storage.address)
    await opTreasury.deployed()
    return opTreasury;
}

export async function unitFixtureGrinder(): Promise<Contract> {
    const Grinder = await ethers.getContractFactory("Grinder")
    const grinder = await Grinder.deploy(punkMock.address)
    await grinder.deployed()
    return grinder;
}

export async function unitFixturePunkRewardPool(): Promise<Contract> {
    const PunkRewardPool = await ethers.getContractFactory("PunkRewardPool")
    const punkRewardPool = await PunkRewardPool.deploy()
    await punkRewardPool.deployed()
    return punkRewardPool;
}

export async function unitFixtureFairLaunch(): Promise<Contract> {
    const FairLaunch = await ethers.getContractFactory("FairLaunch")
    const fairLaunch = await FairLaunch.deploy()
    await fairLaunch.deployed()
    return fairLaunch;
}

export async function unitFixtureUniswapFactoryV2(): Promise<Contract> {
    const IUniswapV2Factory = await artifacts.readArtifact("IUniswapV2FactoryMock");
    const uniswapFactory = await ethers.getContractAt(IUniswapV2Factory.abi, UniswapAddresses.UniswapFactoryV2);
    return uniswapFactory
}