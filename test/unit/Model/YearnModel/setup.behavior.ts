import { expect } from "chai";
import { ethers } from "hardhat";
import { Tokens, CompoundAddresses } from "../../../shared/mockInfo";
import { ethToWei } from "../../../shared/utils";

export function setUpBehavior(): void {
    context("SetUp", function() {

        it('should Success transfer and invest', async function() {
        //    const yearnModel = this.contracts.YearnModel;
        //    this.singers.owner
        //    await yearnModel.connect(this.signers.owner).invest()
        })

        it('should Revert withdrawTo', async function() {
            const yearnModel = this.contracts.YearnModel
            const forge = this.contracts.forge
            await expect(yearnModel.withdrawTo(forge.address, 100)).to.be.reverted
        })

        it('should Revert withdrawToForge', async function() {
            const yearnModel = this.contracts.YearnModel
            await expect(yearnModel.withdrawToForge(100)).to.be.reverted
        })

        it('should Revert withdrawAllToForge', async function() {
            const yearnModel = this.contracts.YearnModel
            await expect(yearnModel.withdrawAllToForge()).to.be.reverted
        })

        it('should return accepted token', async function() {
            const yearnModel = this.contracts.YearnModel;
            await expect(await yearnModel.totalValue()).to.be.eq(0)
        })
        
        it('should check underlying balance', async function() {
            const yearnModel = this.contracts.YearnModel;
            await expect(await yearnModel.underlyingBalanceInModel()).to.be.equal(0)
        })
        
        it('should check underlyingBalanceWithInvestment', async function() {
            const yearnModel = this.contracts.YearnModel;
            await expect(await yearnModel.underlyingBalanceWithInvestment()).to.be.equal(0)
        })
    })
}