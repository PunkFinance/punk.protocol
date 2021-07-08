import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { MockContract } from "ethereum-waffle";

import { Forge } from '../typechain/Forge'
import { ForgeEth } from '../typechain/ForgeEth'

export interface Contracts {
    forge: Forge;
    forgeEth: ForgeEth,
}

export interface Mocks {
    balanceSheet: MockContract;
    fintroller: MockContract;
    hTokens: MockContract[];
    oracle: MockContract;
    usdc: MockContract;
    usdcPriceFeed: MockContract;
    wbtc: MockContract;
    wbtcPriceFeed: MockContract;
    weth: MockContract;
    wethPriceFeed: MockContract;
  }
  
  export interface Signers {
    admin: SignerWithAddress;
    borrower: SignerWithAddress;
    lender: SignerWithAddress;
    liquidator: SignerWithAddress;
    maker: SignerWithAddress;
    raider: SignerWithAddress;
  }
  