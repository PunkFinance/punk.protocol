import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

export function setUpBehavior(): void {
    context("SetUp", function() {
        
        it('should Revert Exceeded Balance', async function() {
            const recoveryFundMock = this.contracts.recoveryFundMock
            const owner = this.signers.owner
            
            await expect(recoveryFundMock.connect(owner).refund(1001)).to.be.reverted;
        })
        
        it('should Revert Insufficient Balance', async function() {
            const recoveryFundMock = this.contracts.recoveryFundMock
            const owner = this.signers.owner

            await expect(recoveryFundMock.connect(owner).refund(1000)).to.be.reverted;
        })


        it('should Success Refund', async function() {
            const accountDai = this.signers.accountDai            
            const daiContract = this.contracts.daiContract
            const recoveryFundMock = this.contracts.recoveryFundMock
            const balance = (await daiContract.balanceOf(accountDai.address)).toString()
            daiContract.connect(accountDai).transfer(recoveryFundMock.address, balance)

            const owner = this.signers.owner
            const beforeBalance = (await daiContract.balanceOf(owner.address)).toString()    
            await recoveryFundMock.connect(owner).refund(500)
            const afterBalance = (await daiContract.balanceOf(owner.address)).toString()
            await expect( BigNumber.from(afterBalance) ).eq( BigNumber.from(beforeBalance).add(500) )
            await expect( await recoveryFundMock.refunded() ).eq( BigNumber.from(beforeBalance).add(500) )
            await expect( await recoveryFundMock.totalSupply() ).eq( BigNumber.from(await recoveryFundMock.totalRefund()).sub(500) )
        })
        
        it('should Revert multiple call to RecoveryFund', async function() {
            const recoveryFundMock = this.contracts.recoveryFundMock
            const owner = this.signers.owner

            const RecoveryFundMultiCallMock = await ethers.getContractFactory("RecoveryFundMultiCallMock")
            const recoveryFundMultiCallMock = await RecoveryFundMultiCallMock.deploy(recoveryFundMock.address)
            await recoveryFundMultiCallMock.deployed()
            
            await recoveryFundMock.connect(owner).transfer( recoveryFundMultiCallMock.address, 500 );
            await recoveryFundMultiCallMock.multiCall()
        })
        
    })
}


export async function unitFixtureRecoveryFund(): Promise<Contract> {
    const RecoveryFundMock = await ethers.getContractFactory("RecoveryFundMock")
    const recoveryFundMock = await RecoveryFundMock.deploy()
    return recoveryFundMock
}
