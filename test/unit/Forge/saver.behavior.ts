import { expect } from "chai"
import { ethers, network } from "hardhat";
import { Tokens } from "../../shared/mockInfo";
import { ethToWei } from '../../shared/utils'

export function saverBehavior(): void {
    context("Saver Behavior", function() {

        before(async function(){
            const daiContract = this.contracts.daiContract
            const uniswapV2Router = this.contracts.uniswapV2Router
            const accountDai = this.signers.accountDai
            
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)

            const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
                ethToWei("10"),
                [Tokens.WETH, Tokens.Dai],
                accountDai.address,
                blockInfo.timestamp + 25*60*60,
                {value: ethToWei("10"), gasLimit: '1300000'}
            )
            await swapResult.wait()
        })

        it('should Revert due to Allowance', async function() {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            const startTimestamp = blockInfo.timestamp + 25 *60 * 60
            await expect(this.contracts.forge['craftingSaver(uint256,uint256,uint256,uint256)'](100, startTimestamp, 1, 1)).to.be.reverted
        })

        it('should Revert due to startTimestamp', async function() {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await expect(this.contracts.forge['craftingSaver(uint256,uint256,uint256,uint256)'](100, blockInfo.timestamp, 1, 1)).to.be.reverted
        })

        it('should Success craftingSaver', async function () {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await this.contracts.daiContract.connect(this.signers.accountDai).approve(this.contracts.forge.address, ethToWei("10"))
            const startTimestamp = blockInfo.timestamp + 25 *60 * 60
            const saverIndex = await this.contracts.forge.connect(this.signers.accountDai).countByAccount(this.signers.accountDai.address)
            
            await expect(this.contracts.forge.connect(this.signers.accountDai)['craftingSaver(uint256,uint256,uint256,uint256)'](1000, startTimestamp, 1, 1))
            .to.emit(this.contracts.forge, 'CraftingSaver')
            .withArgs(this.signers.accountDai.address, saverIndex, 1000)
        })

        it('should Success addDeposit', async function() {
            const prevTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length;
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100)).to.emit(this.contracts.forge, 'AddDeposit').withArgs(this.signers.accountDai.address, 0, 100)
            let afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
            await expect(afterTransactionCount).to.be.eq(prevTransactionCount, "Transaction is not added");

            // increase time 86400 secs
            await network.provider.send("evm_increaseTime", [86400]);
            await network.provider.send("evm_mine")
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100))
                .to.emit(this.contracts.forge, 'AddDeposit')
                .withArgs(this.signers.accountDai.address, 0, 100)
            
                afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
            
            await expect(afterTransactionCount).to.be.eq(prevTransactionCount + 1, "Transaction is not added");
        })

        it('should Revert withdraw Not yet', async function() {
            const withdrawbleAmount = await this.contracts.forge.withdrawable(this.signers.accountDai.address, 0)
            await this.contracts.forge.connect(this.signers.accountDai).withdraw(0, withdrawbleAmount.div(2))
        })

        it('should Success withdraw', async function() {
            await network.provider.send("evm_increaseTime", [86400]);
            await network.provider.send("evm_mine")

            const withdrawbleAmount = await this.contracts.forge.withdrawable(this.signers.accountDai.address, 0)
            await this.contracts.forge.connect(this.signers.accountDai).withdraw(10, withdrawbleAmount.div(2))
        })

        it('should Success terminateSaver', async function() {
            await this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)
            await expect(this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).withdraw(0, 100)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100)).to.be.reverted
        })

    })
    
}