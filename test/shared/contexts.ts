// eslint-disable @typescript-eslint/no-explicit-any
import { Signer } from "@ethersproject/abstract-signer";
import { Wallet } from "@ethersproject/wallet";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers, waffle } from "hardhat";

import { Contracts, Mocks, Signers } from "../../types/index";

const { createFixtureLoader } = waffle;

/// This is run at the beginning of each suite of tests: 2e2, integration and unit.
export function baseContext(description: string, hooks: () => void): void {
  describe(description, function () {
    before(async function () {
      this.contracts = {} as Contracts;
      this.mocks = {} as Mocks;
      this.signers = {} as Signers;

      const signers: SignerWithAddress[] = await ethers.getSigners();
      this.signers.owner = signers[5];
      this.signers.accountDai = signers[0];
      this.signers.account1 = signers[1];
      this.signers.account2 = signers[2];
      this.signers.account3 = signers[3];
      this.signers.account4 = signers[4];

      // Get rid of this when https://github.com/nomiclabs/hardhat/issues/849 gets fixed.
      this.loadFixture = createFixtureLoader(signers as Signer[] as Wallet[]);
    });

    hooks();
  });
}
