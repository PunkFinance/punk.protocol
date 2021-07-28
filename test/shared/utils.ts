import { ethers } from "hardhat";

export function ethToWei(amount: string): string {
    return ethers.BigNumber.from(ethers.utils.parseEther(amount).toString()).toString()
}