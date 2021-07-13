import { expect } from "chai"
import { ethers } from "hardhat";
import { Tokens } from "../../../shared/mockInfo";

export default function shouldBehaveLikeCraftingSaver(): void {
    context("craftingSaver called", function() {
        beforeEach(async function() {
            const swapResult = await this.contracts.uniswapV2Router.connect(this.signers.accountDai).swapExactETHForTokens(
                100,
                [Tokens.WETH, Tokens.Dai],
                this.signers.accountDai.address,
                Math.round(Date.now() / 1000) + 100000000000000,
                {value: ethers.BigNumber.from(ethers.utils.parseEther("1000").toString()).toHexString(), gasLimit: '1300000'}
            )
            await swapResult.wait()
        })

        it('should revert due to startTimestamp', async function() {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await expect(this.contracts.forge.craftingSaver(100, blockInfo.timestamp, 100, 1000)).to.be.reverted
        })

        it('should save', async function () {
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            await this.contracts.daiContract.connect(this.signers.accountDai).approve(this.contracts.forge.address, 10000)
            const startTimestamp = blockInfo.timestamp + 25 *60 * 60
            const saverIndex = await this.contracts.forge.connect(this.signers.accountDai).countByAccount(this.signers.accountDai.address)
            await expect(this.contracts.forge.connect(this.signers.accountDai).craftingSaver(10000, startTimestamp, 100, 1000))
            .to.emit(this.contracts.forge, 'CraftingSaver')
            .withArgs(this.signers.accountDai.address, saverIndex, 10000)
        })
    })
}