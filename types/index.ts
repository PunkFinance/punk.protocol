import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import { Forge } from '../typechain/Forge'
import { ForgeEth } from '../typechain/ForgeEth'

export interface Contracts {
    forge: Forge;
    forgeEth: ForgeEth,
}
  
  export interface Signers {
    owner: SignerWithAddress;
    accountDai: SignerWithAddress;
    account1: SignerWithAddress;
    account2: SignerWithAddress;
    account3: SignerWithAddress;
    account4: SignerWithAddress;
  }
  