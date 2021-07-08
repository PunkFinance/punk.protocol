import { Signer } from "@ethersproject/abstract-signer"
import { Contract } from "ethers";
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