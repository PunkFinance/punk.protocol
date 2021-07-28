import { Contract, Wallet } from "ethers";
import { artifacts, ethers, waffle } from "hardhat"
import { Tokens, UniswapAddresses } from "./mockInfo";

export async function libraryFixtures(): Promise<Contract> {
    const CommitmentWeight = await ethers.getContractFactory("CommitmentWeight")
    const commietmentWeight = await CommitmentWeight.deploy()
    await commietmentWeight.deployed()

    const Score = await ethers.getContractFactory("Score", {
        libraries: {
            CommitmentWeight: commietmentWeight.address
        }
    });
    const score = await Score.deploy()
    await score.deployed();

    return score
}

export async function unitFixtureForge(): Promise<Contract> {
    const score = await libraryFixtures();
    const Forge = await ethers.getContractFactory("Forge", {
        libraries: {
            Score: score.address,
        }
    });
    const forge = await Forge.deploy()
    await forge.deployed();
    return forge;
}

export async function unitFixtureVariables([owner] : Wallet[]): Promise<Contract> {
    const Variables = await ethers.getContractFactory("Variables")
    const variables = await Variables.deploy(owner.address)
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
    const IUniswapV2Router = await artifacts.readArtifact("IUniswapV2Router02");
    const uniswapRouter = await ethers.getContractAt(IUniswapV2Router.abi, UniswapAddresses.UniswapV2Router02);
    return uniswapRouter
}

export async function unitFixtureDaiToken(): Promise<Contract> {
    const IDaiToken = await artifacts.readArtifact("IERC20")
    const daiToken = await ethers.getContractAt(IDaiToken.abi, Tokens.Dai)
    return daiToken
}

export async function unitFixtureOwnableStorage([,,,,,owner] : Wallet[]): Promise<Contract> {
    const OwnableStorage = await ethers.getContractFactory("OwnableStorage")
    const ownableStorage = await OwnableStorage.connect(owner).deploy()
    await ownableStorage.deployed()
    return ownableStorage
}

export async function unitFixtureScoreMock(): Promise<Contract> {
    const score = await libraryFixtures();
    const ScoreMock = await ethers.getContractFactory("ScoreMock", {
        libraries: {
            Score: score.address,
        }
    });
    const scoreMock = await ScoreMock.deploy()

    return scoreMock
}