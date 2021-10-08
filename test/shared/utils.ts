import { ParamType } from "@ethersproject/abi";
import { ethers } from "hardhat";

export function ethToWei(amount: string): string {
    return ethers.BigNumber.from(ethers.utils.parseEther(amount).toString()).toString()
}

export function abiEncode( types: ReadonlyArray<string | ParamType>, values: ReadonlyArray<any> ):string{
    return ethers.utils.defaultAbiCoder.encode(types, values)
}