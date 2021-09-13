import { expect } from "chai";
import { ethers } from "hardhat";
import { Tokens, CompoundAddresses } from "../../../shared/mockInfo";
import { ethToWei } from "../../../shared/utils";

export function setUpBehavior(): void {
    context("SetUp", function() {

        it('should Success transfer and invest', async function() {
            // const compoundModel = this.contracts.compoundModel
            
            // const daiContract = this.contracts.daiContract
            // const uniswapV2Router = this.contracts.uniswapV2Router
            // const accountDai = this.signers.accountDai
            
            // const blockNumber = await ethers.provider.getBlockNumber()
            // const blockInfo = await ethers.provider.getBlock(blockNumber)

            // const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
            //     ethToWei("10"),
            //     [Tokens.WETH, Tokens.Dai],
            //     accountDai.address,
            //     blockInfo.timestamp + 25*60*60,
            //     {value: ethToWei("10"), gasLimit: '1300000'}
            // )
            // await swapResult.wait()
            
            // console.log( "balanceOf", ( await daiContract.balanceOf( accountDai.address ) ).toString() )
            // await expect( compoundModel.withdrawTo( forge.address, 100 ) ).to.be.reverted
            
            // const CDAI = await ethers.getContractAt("CTokenInterface", CompoundAddresses.cDai );
            // console.log("CDAI", CDAI)
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