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
            const compoundModel = this.contracts.compoundModel
            const forge = this.contracts.forge
            await expect( compoundModel.withdrawTo( forge.address, 100 ) ).to.be.reverted
        })

        it('should Revert withdrawToForge', async function() {
            const compoundModel = this.contracts.compoundModel
            await expect( compoundModel.withdrawToForge( 100 ) ).to.be.reverted
        })

        it('should Revert withdrawAllToForge', async function() {
            const compoundModel = this.contracts.compoundModel
            await expect( compoundModel.withdrawAllToForge() ).to.be.reverted
        })

    })
    
}