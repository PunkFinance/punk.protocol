import { Tokens } from "../../shared/mockInfo"
import { expect } from "chai";
import { ethers } from "hardhat";

export function setUpBehavior(): void {
    context("SetUp", function() {
        
        it('should Revert addAsset Address Not AdminOrGovernance', async function() {
            const treasury = this.contracts.treasury
            const account1 = this.signers.account1
            await expect( treasury.connect(account1).addAsset(Tokens.Dai) ).to.be.reverted
        })
        
        it('should Success addAsset', async function() {
            const treasury = this.contracts.treasury
            const owner = this.signers.owner
            await expect(treasury.connect(owner).addAsset(Tokens.Dai)).emit(treasury, "AddAsset").withArgs(Tokens.Dai);
        })

        it('should Revert addAsset Already Registry Token', async function() {
            const treasury = this.contracts.treasury
            const owner = this.signers.owner
            await expect(treasury.connect(owner).addAsset(Tokens.Dai)).to.be.reverted
        })
        
        it('should Revert addAsset Buyback Test', async function() {
            const treasury = this.contracts.treasury
            const owner = this.signers.owner
            await treasury.connect(owner).buyBack()
        })
        
        // it('should Revert addAsset Buyback Test', async function() {
        //     const treasury = this.contracts.treasury
        //     const owner = this.signers.owner
        //     const DAI = this.contracts.daiContract
        //     const swapResult = await this.contracts.uniswapV2Router.connect(this.signers.owner).swapExactETHForTokens(
        //         10000000000,
        //         [Tokens.WETH, Tokens.Dai],
        //         treasury.address,
        //         Math.round(Date.now() / 1000) + 100000000000000,
        //         {value: "100000000000000000000", gasLimit: '2300000'}
        //     )
        //     await swapResult.wait()
        //     await treasury.connect(owner).buyBack()
        // })

    })
}