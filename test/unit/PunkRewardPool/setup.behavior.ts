import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";

export function setUpBehavior(): void {
    context("SetUp", function() {

        it('should Revert addForge Not Admin', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const account1 = this.signers.account1
            await expect( rewardPool.connect(account1).addForge( forge.address ) ).to.be.reverted
        })

        it('should Revert addForge address Gov', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const gov = this.signers.gov
            await expect( rewardPool.connect(gov).addForge( forge.address ) ).to.be.reverted
        })

        it('should Revert addForge Not Contract Address', async function() {
            const rewardPool = this.contracts.rewardPool
            const owner = this.signers.owner
            await expect( rewardPool.connect(owner).addForge( owner.address ) ).to.be.reverted
        })

        it('should Success addForge 3 Items', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const forge2nd = this.contracts.forge2
            const forge3rd = this.contracts.forge3
            const owner = this.signers.owner
            
            await expect( rewardPool.connect(owner).addForge( forge.address ) ).emit(rewardPool, "AddForge").withArgs(forge.address)
            await expect( rewardPool.connect(owner).addForge( forge2nd.address ) ).emit(rewardPool, "AddForge").withArgs(forge2nd.address)
            await expect( rewardPool.connect(owner).addForge( forge3rd.address ) ).emit(rewardPool, "AddForge").withArgs(forge3rd.address)

            await expect( await rewardPool.checkForge( forge.address ) ).eq(true)
            await expect( await rewardPool.checkForge( forge2nd.address ) ).eq(true)
            await expect( await rewardPool.checkForge( forge3rd.address ) ).eq(true)
        })

        it('should Revert addForge Already Exist', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const owner = this.signers.owner
            await expect( rewardPool.connect(owner).addForge( forge.address ) ).to.be.reverted
        })

        it('should Success setForge', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const owner = this.signers.owner
            const weight = 150
            await expect( rewardPool.connect(owner).setForge( forge.address, weight ) ).emit(rewardPool, "SetForge").withArgs(forge.address, weight)
            await expect( await rewardPool.getWeight(forge.address) ).equal(weight)
        })

        it('should Check getWeightSum', async function() {
            const rewardPool = this.contracts.rewardPool
            const forge = this.contracts.forge
            const forge2nd = this.contracts.forge2
            const forge3rd = this.contracts.forge3

            const forgeWeight = await rewardPool.getWeight( forge.address )
            const forge2ndWeight = await rewardPool.getWeight( forge2nd.address )
            const forge3rdWeight = await rewardPool.getWeight( forge3rd.address )

            await expect( await rewardPool.getWeightSum() ).eq( Number(forgeWeight) + Number(forge2ndWeight) + Number(forge3rdWeight) )
        })

        it('should Revert start Not Admin', async function() {
            const rewardPool = this.contracts.rewardPool
            const account1 = this.signers.account1
            await expect( rewardPool.connect(account1).start()).to.be.reverted
        })

        it('should Success start', async function() {
            const rewardPool = this.contracts.rewardPool
            const owner = this.signers.owner
            await expect( rewardPool.connect(owner).start()).emit(rewardPool,"Start")
            const blockNumber = await ethers.provider.getBlockNumber()
            await expect( (await rewardPool.getStartBlock()).toNumber()).eq(blockNumber)
        })

        it('should Revert start already started', async function() {
            const rewardPool = this.contracts.rewardPool
            const owner = this.signers.owner
            await expect( rewardPool.connect(owner).start()).to.be.reverted
        })

    })
    
}