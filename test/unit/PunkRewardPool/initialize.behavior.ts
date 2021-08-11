import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethToWei } from "../../shared/utils"

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success RewardPool Initialize', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const rewardPool = this.contracts.rewardPool;
            const punkMock = this.contracts.punkMock;
            const owner = this.signers.owner;

            await expect(rewardPool.connect(owner).initializeReward(ownableStorage.address, punkMock.address)).emit(rewardPool, "Initialize")
        })

        it('should Revert Already initialized', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const rewardPool = this.contracts.rewardPool;
            const punkMock = this.contracts.punkMock;
            const owner = this.signers.owner;
            await expect(rewardPool.connect(owner).initializeReward(ownableStorage.address, punkMock.address)).to.be.reverted
        })

        it('should Success Transfer Punk For RewardPool', async function() {
            const punkMock = this.contracts.punkMock
            const rewardPool = this.contracts.rewardPool
            const owner = this.signers.owner
            await punkMock.connect(owner).transfer( rewardPool.address, ethToWei("10500000") );
            await expect( await punkMock.balanceOf(rewardPool.address) ).eq(BigNumber.from(ethToWei("10500000")))
            await expect( await rewardPool.getTotalReward() ).eq(BigNumber.from(ethToWei("10500000")))
        })

    })
}