import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

export function setUpBehavior(): void {
  context("SetUp", function () {
    it("should Revert startRefund Address Not Admin", async function () {
      const recoveryFundMock = this.contracts.recoveryFundMock;
      const account1 = this.signers.account1;
      await expect(
        recoveryFundMock.connect(account1).startRefund()
      ).to.be.reverted;
    });

    it("should Revert stopRefund Address Not Admin", async function () {
      const recoveryFundMock = this.contracts.recoveryFundMock;
      const account1 = this.signers.account1;
      await expect(
        recoveryFundMock.connect(account1).stopRefund()
      ).to.be.reverted;
    });

    it("should Revert stopRefund Not Opend", async function () {
      const recoveryFundMock = this.contracts.recoveryFundMock;
      const owner = this.signers.owner;
      await expect(
        recoveryFundMock.connect(owner).stopRefund()
      ).to.be.reverted;
    });

    it("should Success startRefund", async function () {
      const recoveryFundMock = this.contracts.recoveryFundMock;
      const owner = this.signers.owner;
      await recoveryFundMock.connect(owner).startRefund();
      await expect(recoveryFundMock.connect(owner).startRefund()).to.be.reverted
    });

    it("should Success stopRefund", async function () {
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const owner = this.signers.owner;
        await recoveryFundMock.connect(owner).stopRefund();
        await expect(recoveryFundMock.connect(owner).stopRefund()).to.be.reverted
    });

    it("should Revert emergency Not Owner address", async function () {
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const account1 = this.signers.account1;
        await expect(recoveryFundMock.connect(account1).emergency()).to.be.reverted
    });

    it("should Success emergency", async function () {
        const daiContract = this.contracts.daiContract;
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const owner = this.signers.owner;

        const balanceOfOwnerBeforeEmergency = (await daiContract.balanceOf(owner.address)).toString();
        const balanceOfRecoveryFunds = (await daiContract.balanceOf(recoveryFundMock.address)).toString();
        await recoveryFundMock.connect(owner).emergency();
        const balanceOfOwnerAfterEmergency = (await daiContract.balanceOf(owner.address)).toString();

        await expect( (await daiContract.balanceOf(recoveryFundMock.address)).toString() ).eq("0");
        await expect( BigNumber.from(balanceOfOwnerAfterEmergency) ).eq( BigNumber.from(balanceOfOwnerBeforeEmergency).add(balanceOfRecoveryFunds) );        
    });

    it("should Check balanceOfDai", async function () {
        const daiContract = this.contracts.daiContract;
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const owner = this.signers.owner;

        const balanceOfOwner = (await daiContract.balanceOf(owner.address)).toString();
        await daiContract.connect(owner).transfer( recoveryFundMock.address, balanceOfOwner );
        const balanceOfRecoveryFunds = (await recoveryFundMock.balanceOfDai()).toString();        
        
        await expect( balanceOfRecoveryFunds ).eq(balanceOfOwner);
    });

    it("should Revert refund Not Opened", async function () {
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const account1 = this.signers.account1;
        await expect(recoveryFundMock.connect(account1).refund(10000)).to.be.reverted
    });

    it("should Success startRefund", async function () {
      const recoveryFundMock = this.contracts.recoveryFundMock;
      const owner = this.signers.owner;
      await recoveryFundMock.connect(owner).startRefund();
      await expect(recoveryFundMock.connect(owner).startRefund()).to.be.reverted
    });

    it("should Revert refund sender's balance is insufficient", async function () {
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const account1 = this.signers.account1;
        await expect(recoveryFundMock.connect(account1).refund(10001)).to.be.reverted
    });

    it("should Success refund", async function () {
        const daiContract = this.contracts.daiContract;
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const account1 = this.signers.account1;

        const balanceOfOwnerBeforeRefund = (await daiContract.balanceOf(account1.address)).toString();
        await recoveryFundMock.connect(account1).refund(10000)
        const balanceOfOwnerAfterRefund = (await daiContract.balanceOf(account1.address)).toString();
        await expect( BigNumber.from(balanceOfOwnerAfterRefund).toString() ).equal(BigNumber.from(balanceOfOwnerBeforeRefund).add(10000).toString())
    });

  });
}
