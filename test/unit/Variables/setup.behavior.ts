import { expect } from "chai";

export function setUpBehavior(): void {
  context("SetUp", function () {
    it("should Revert setRewardPool Address Not Admin", async function () {
      const variables = this.contracts.variables;
      const rewardPool = this.contracts.rewardPool;
      const account1 = this.signers.account1;
      await expect(
        variables.connect(account1).setReward(rewardPool.address)
      ).to.be.reverted;
    });

    it("should Revert setRewardPool Address Not Contract", async function () {
      const variables = this.contracts.variables;
      const owner = this.signers.owner;
      const account1 = this.signers.account1;
      await expect(variables.connect(owner).setReward(account1)).to.be.reverted;
    });

    it("should Success setRewardPool Address", async function () {
      const variables = this.contracts.variables;
      const rewardPool = this.contracts.rewardPool;
      const owner = this.signers.owner;
      await variables.connect(owner).setReward(rewardPool.address);
      await expect(await variables.reward()).to.be.eq(rewardPool.address);
    });

    it("should Revert setTreasury Address Not Admin", async function () {
      const variables = this.contracts.variables;
      // const treasury = this.contracts.treasury;
      const treasury = this.contracts.opTreasury;
      const account1 = this.signers.account1;
      await expect(
        variables.connect(account1).setTreasury(treasury.address)
      ).to.be.reverted;
    });

    it("should Revert setTreasury Address Not Contract", async function () {
      const variables = this.contracts.variables;
      const owner = this.signers.owner;
      const account1 = this.signers.account1;
      await expect(
        variables.connect(owner).setTreasury(account1)
      ).to.be.reverted;
    });

    it("should Success setTreasury Address", async function () {
      const variables = this.contracts.variables;
      // const treasury = this.contracts.treasury;
      const treasury = this.contracts.opTreasury;
      const owner = this.signers.owner;
      await variables.connect(owner).setTreasury(treasury.address);
      await expect(await variables.treasury()).to.be.eq(treasury.address);
    });

    it("should Revert setSuccessFee Address Not Gov and Admin", async function () {
      const variables = this.contracts.variables;
      const account1 = this.signers.account1;
      await expect(variables.connect(account1).setSuccessFee(20)).to.be.reverted;
    });

    it("should Revert setSuccessFee Address Admin", async function () {
      const variables = this.contracts.variables;
      const owner = this.signers.owner;
      await expect(variables.connect(owner).setSuccessFee(20)).to.be.reverted;
    });

    it("should Success setSuccessFee", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      const fee = 20;
      await variables.connect(gov).setSuccessFee(fee);
      await expect(await variables.successFee()).to.be.eq(fee);
    });

    it("should Revert setSuccessFee Overflow Valeus", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      const fee = 21;
      await expect(variables.connect(gov).setSuccessFee(fee)).to.be.reverted;
    });

    it("should Revert setServiceFee Address Not Gov and Admin", async function () {
      const variables = this.contracts.variables;
      const account1 = this.signers.account1;
      await expect(variables.connect(account1).setServiceFee(10)).to.be.reverted;
    });

    it("should Revert setServiceFee Address Admin", async function () {
      const variables = this.contracts.variables;
      const owner = this.signers.owner;
      const fee = 1;
      await expect(variables.connect(owner).setServiceFee(fee)).to.be.reverted;
    });

    it("should Success setServiceFee", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      const fee = 1;
      await variables.connect(gov).setServiceFee(fee);
      await expect(await variables.serviceFee()).to.be.eq(fee);
    });

    it("should Revert setServiceFee Overflow Valeus", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      await expect(variables.connect(gov).setServiceFee(10)).to.be.reverted;
    });

    it("should Revert setFeeMultiplier Address Not Gov and Admin", async function () {
      const variables = this.contracts.variables;
      const account1 = this.signers.account1;
      await expect(
        variables.connect(account1).setFeeMultiplier(100)
      ).to.be.reverted;
    });

    it("should Revert setFeeMultiplier Address Admin", async function () {
      const variables = this.contracts.variables;
      const owner = this.signers.owner;
      await expect(variables.connect(owner).setFeeMultiplier(100)).to.be.reverted;
    });

    it("should Success setFeeMultiplier", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      const fee = 200;
      await variables.connect(gov).setFeeMultiplier(fee);
      await expect(await variables.feeMultiplier()).to.be.eq(fee);
    });

    it("should Revert setFeeMultiplier Overflow Valeus", async function () {
      const variables = this.contracts.variables;
      const gov = this.signers.gov;
      await expect(variables.connect(gov).setFeeMultiplier(300)).to.be.reverted;
    });
  });
}
