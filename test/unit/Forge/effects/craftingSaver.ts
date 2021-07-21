import { expect, use } from "chai"
import { ethers, network } from "hardhat";
import { Tokens } from "../../../shared/mockInfo";
import { ethToWei } from '../../../shared/utils'


export default function shouldBehaveLikeCraftingSaver(): void {
    context("craftingSaver called", function() {
        beforeEach(async function() {
            const swapResult = await this.contracts.uniswapV2Router.connect(this.signers.accountDai).swapExactETHForTokens(
                100,
                [Tokens.WETH, Tokens.Dai],
                this.signers.accountDai.address,
                Math.round(Date.now() / 1000) + 100000000000000,
                {value: ethToWei("1000"), gasLimit: '1300000'}
            )
            await swapResult.wait()
            await this.contracts.daiContract.connect(this.signers.accountDai).transfer(this.signers.account1.address, ethToWei("100"))
            await this.contracts.forge.connect(this.signers.account1).approve(this.contracts.forge.address, ethToWei("100"))
            await this.contracts.daiContract.connect(this.signers.accountDai).approve(this.contracts.forge.address, ethToWei("100000"))
        })

        it('should revert due to startTimestamp', async function() {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await expect(this.contracts.forge.craftingSaver(100, blockInfo.timestamp, 100, 1000)).to.be.reverted
        })

        it('should save craft works', async function () {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await this.contracts.daiContract.connect(this.signers.accountDai).approve(this.contracts.forge.address, ethToWei("10"))
            const startTimestamp = blockInfo.timestamp + 25 *60 * 60
            const saverIndex = await this.contracts.forge.connect(this.signers.accountDai).countByAccount(this.signers.accountDai.address)
            await expect(this.contracts.forge.connect(this.signers.accountDai).craftingSaver(ethToWei("10"), startTimestamp, 100, 1000))
            .to.emit(this.contracts.forge, 'CraftingSaver')
            .withArgs(this.signers.accountDai.address, saverIndex, ethToWei("10"))
        })

        it('check addDeposit works correctly', async function() {
            const account1Count = await this.contracts.forge.countByAccount(this.signers.accountDai.address);
            const prevTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length;
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, ethToWei('10')))
                .to.emit(this.contracts.forge, 'AddDeposit')
                .withArgs(this.signers.accountDai.address, 0, ethToWei('10'))
            let afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
            await expect(afterTransactionCount).to.be.eq(prevTransactionCount, "Transaction is not added");

            // increase time 86400 secs
            await network.provider.send("evm_increaseTime", [86400]);
            await network.provider.send("evm_mine")
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, ethToWei('10')))
                .to.emit(this.contracts.forge, 'AddDeposit')
                .withArgs(this.signers.accountDai.address, 0, ethToWei('10'))
            afterTransactionCount = (await this.contracts.forge.transactions(this.signers.accountDai.address, 0)).length
                await expect(afterTransactionCount)
                .to.be.eq(prevTransactionCount + 1, "Transaction is not added");
        })

        it('check withdraw', async function() {
            await network.provider.send("evm_increaseTime", [86400]);
            await network.provider.send("evm_mine")

            const withdrawbleAmount = await this.contracts.forge.withdrawable(this.signers.accountDai.address, 0)
            await this.contracts.forge.connect(this.signers.accountDai).withdraw(0, withdrawbleAmount.div(2))
        })

        it('check terminateSaver', async function() {
            await this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)
            await expect(this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).withdraw(0, 100)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100)).to.be.reverted
        })

        it('check score model', async function() {
            
        })
    })
}