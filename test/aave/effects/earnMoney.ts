import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, upgrades } from "hardhat";
import { advanceHours, formatValue } from "../../../src/utils/index";
import { BigNumber, Contract } from "ethers";
import { expect } from "chai";

export default function shouldEarnMoney(): void {
  context("earning money with contract address", function () {
    it("farmer earns money", async function () {
      const initialFarmerBalance: BigNumber =
        await this.contracts.daiContract.balanceOf(
          this.signers.accountDai.address
        );
      console.log(this.signers.accountDai.address);
      await this.contracts.daiContract
        .connect(this.signers.accountDai)
        .approve(this.contracts.forge.address, initialFarmerBalance);
      await this.contracts.forge
        .connect(this.signers.accountDai)
        .deposit(initialFarmerBalance, this.signers.accountDai.address);
      let oldSharePrice: BigNumber;
      let newSharePrice: BigNumber;
      for (let i = 0; i < 10; i++) {
        console.log(`Loop ${i}`);

        oldSharePrice = await this.contracts.forge.getExchangeRate();
        await this.contracts.forge.connect(this.signers.owner).doHardWork();
        newSharePrice = await this.contracts.forge.pricePerShare();

        console.log(
          `Old share price: ${await formatValue(
            this.contracts.forge,
            oldSharePrice
          )}`
        );
        console.log(
          `New share price: ${await formatValue(
            this.contracts.forge,
            newSharePrice
          )}`
        );

        await advanceHours(12);
      }
    });
  });
}
