import { Signer } from "@ethersproject/abstract-signer"
import { Contract, Wallet } from "ethers";
import { artifacts, ethers, waffle } from "hardhat"

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