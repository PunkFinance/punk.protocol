import { expect } from "chai"
import { BigNumber } from "ethers";
import { ethers, network } from "hardhat";
import { Tokens } from "../../shared/mockInfo";
import { ethToWei } from '../../shared/utils'

export function saverBehavior(): void {
    context("Saver Behavior", function() {

        before(async function(){
            const uniswapV2Router = this.contracts.uniswapV2Router
            const accountDai = this.signers.accountDai
            
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)

            const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
                1,
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
            const forge = this.contracts.forge;

            await expect(forge.craftingSaver(100, startTimestamp, 1, 2)).to.be.reverted
        })

        it('should Revert due to startTimestamp', async function() {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            const forge = this.contracts.forge;
            
            await expect(forge.craftingSaver(100, blockInfo.timestamp, 1, 2)).to.be.reverted
        })

        it('should Success craftingSaver', async function () {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            const account = this.signers.accountDai
            const forge = this.contracts.forge
            const daiContract = this.contracts.daiContract

            const startTimestamp = blockInfo.timestamp + 25 *60 * 60
            const saverIndex = await forge.connect(account).countByAccount(account.address)
            const balance = await daiContract.balanceOf( account.address );
            
            await daiContract.connect(account).approve(forge.address, ethToWei("100000"))
            await expect(forge
                .connect(account).craftingSaver( ethToWei("1") , startTimestamp, 2, 4))
                .to.emit(forge, 'CraftingSaver')
                .withArgs(account.address, saverIndex, ethToWei("1") )
            
            const saverIndex2 = await forge.connect(account).countByAccount(account.address)
            await expect(forge
                .connect(account).craftingSaver( ethToWei("1") , startTimestamp, 2, 4))
                .to.emit(forge, 'CraftingSaver')
                .withArgs(account.address, saverIndex2, ethToWei("1") )

        })

        it('should Success addDeposit', async function() {
            const account = this.signers.accountDai
            const forge = this.contracts.forge
            const daiContract = this.contracts.daiContract;
            const balance = await daiContract.balanceOf( account.address );
            // await expect(forge.connect(account).addDeposit(0, balance.div(3).toString())).to.emit(forge, 'AddDeposit').withArgs(account.address, 0, balance.div(3).toString())
            await expect(forge.connect(account).addDeposit(0, ethToWei("1"))).to.emit(forge, 'AddDeposit').withArgs(account.address, 0, ethToWei("1"))
        })

        it('should Revert withdraw Not yet', async function() {
            const forge = this.contracts.forge;
            const account = this.signers.accountDai
            await expect( forge.connect(account).withdraw(1) ).to.be.reverted
        })

        it('should Success withdraw', async function() {
            await network.provider.send("evm_increaseTime", [106400]);
            await network.provider.send("evm_mine")

            const forge = this.contracts.forge;
            const account = this.signers.accountDai

            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            const withdrawable = await forge.connect(account).withdrawable(account.address, 0);
            await expect(forge.connect(account).withdraw(0, withdrawable.toString())).emit(forge, "Withdraw")
        })

        it('should Success terminateSaver', async function() {
            await network.provider.send("evm_increaseTime", [306400]);
            await network.provider.send("evm_mine")

            const forge = this.contracts.forge;
            const compoundModel = this.contracts.compoundModel;
            const account = this.signers.accountDai
            const daiContract = this.contracts.daiContract

            await daiContract.connect(account).transfer(compoundModel.address, ethToWei("1"));
            const saver = await forge.saver(account.address, 0);

            const _withdrawValues = await forge.connect(account)._withdrawValues(account.address, 0, BigNumber.from(saver.mint).sub(saver.released).toString(), true );

            await this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)
            await expect(this.contracts.forge.connect(this.signers.accountDai).terminateSaver(0)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).withdraw(0, 100)).to.be.reverted
            await expect(this.contracts.forge.connect(this.signers.accountDai).addDeposit(0, 100)).to.be.reverted
        })

    })
    
}