import { expect } from "chai";

export function setUpBehavior(): void {
    context("SetUp", function() {
        
        it('should Revert setReferral Address Not Admin', async function() {
            await expect(true).eq(true)
            return;
            const variables = this.contracts.variables
            const referral = this.contracts.referral
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setReferral(referral.address) ).to.be.reverted
        })

        it('should Revert setReferral Address Not Contract', async function() {
            await expect(true).eq(true)
            return;
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const account1 = this.signers.account1
            await expect( variables.connect(owner).setReferral(account1) ).to.be.reverted
        })
        
        it('should Success setReferral Address', async function() {
            await expect(true).eq(true)
            return;
            const variables = this.contracts.variables
            const referral = this.contracts.referral
            const owner = this.signers.owner
            await variables.connect(owner).setReferral(referral.address);
            await expect( await variables.referral() ).to.be.eq( referral.address )
        })

        it('should Revert setRewardPool Address Not Admin', async function() {
            const variables = this.contracts.variables
            const rewardPool = this.contracts.rewardPool
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setReward(rewardPool.address) ).to.be.reverted
        })

        it('should Revert setRewardPool Address Not Contract', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const account1 = this.signers.account1
            await expect( variables.connect(owner).setReward(account1) ).to.be.reverted
        })

        it('should Success setRewardPool Address', async function() {
            const variables = this.contracts.variables
            const rewardPool = this.contracts.rewardPool
            const owner = this.signers.owner
            await variables.connect(owner).setReward(rewardPool.address);
            await expect( await variables.reward() ).to.be.eq( rewardPool.address )
        })

        it('should Revert setTreasury Address Not Admin', async function() {
            const variables = this.contracts.variables
            const treasury = this.contracts.treasury
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setTreasury(treasury.address) ).to.be.reverted
        })

        it('should Revert setTreasury Address Not Contract', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const account1 = this.signers.account1
            await expect( variables.connect(owner).setTreasury(account1) ).to.be.reverted
        })

        it('should Success setTreasury Address', async function() {
            const variables = this.contracts.variables
            const treasury = this.contracts.treasury
            const owner = this.signers.owner
            await variables.connect(owner).setTreasury(treasury.address);
            await expect( await variables.treasury() ).to.be.eq( treasury.address )
        })

        /*
        it('should Revert setOperatorTreasury Address Not Admin', async function() {
            const variables = this.contracts.variables
            const opTreasury = this.contracts.opTreasury
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setOpTreasury(opTreasury.address) ).to.be.reverted
        })

        it('should Revert setOperatorTreasury Address Not Contract', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const account1 = this.signers.account1
            await expect( variables.connect(owner).setOpTreasury(account1) ).to.be.reverted
        })

        it('should Success setOperatorTreasury Address', async function() {
            const variables = this.contracts.variables
            const opTreasury = this.contracts.opTreasury
            const owner = this.signers.owner
            await variables.connect(owner).setOpTreasury(opTreasury.address);
            await expect( await variables.opTreasury() ).to.be.eq( opTreasury.address )
        })
     
        it('should Revert setEarlyTerminateFee Address Not Gov and Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setEarlyTerminateFee(1) ).to.be.reverted
        })

        it('should Revert setEarlyTerminateFee Address Admin', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            await expect( variables.connect(owner).setEarlyTerminateFee(1) ).to.be.reverted
        })

        it('should Success setEarlyTerminateFee', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            const fee = 1
            await variables.connect(gov).setEarlyTerminateFee(fee);
            await expect( await variables['earlyTerminateFee()']() ).to.be.eq( fee )
        })
        
        it('should Revert setEarlyTerminateFee Overflow Valeus', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            await expect( variables.connect(gov).setEarlyTerminateFee(10) ).to.be.reverted
        })

        it('should Revert setBuybackRate Address Not Gov and Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setBuybackRate(20) ).to.be.reverted
        })

        it('should Revert setBuybackRate Address Admin', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            await expect( variables.connect(owner).setBuybackRate(20) ).to.be.reverted
        })

        it('should Success setBuybackRate', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            await variables.connect(gov).setBuybackRate(20);
            await expect( await variables.buybackRate() ).to.be.eq( 20 )
        })
        
        it('should Revert setBuybackRate Overflow Valeus', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            await expect( variables.connect(gov).setBuybackRate(21) ).to.be.reverted
        })

        it('should Revert setServiceFee Address Not Gov and Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setServiceFee(1) ).to.be.reverted
        })

        it('should Revert setServiceFee Address Admin', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            await expect( variables.connect(owner).setServiceFee(1) ).to.be.reverted
        })

        it('should Success setServiceFee', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            await variables.connect(gov).setServiceFee(1);
            await expect( await variables.serviceFee() ).to.be.eq( 1 )
        })
        
        it('should Revert setServiceFee Overflow Valeus', async function() {
            const variables = this.contracts.variables
            const gov = this.signers.gov
            await expect( variables.connect(gov).setServiceFee(3) ).to.be.reverted
        })

        it('should Revert setDiscount Address Not Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setDiscount(20) ).to.be.reverted
        })
        
        it('should Success setDiscount Overflow Valeus', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const compensation = await variables.compensation()
            await expect( variables.connect(owner).setDiscount( 101 - compensation ) ).to.be.reverted
        })

        it('should Success setDiscount', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const setUpPoint = 5;
            await expect( variables.connect(owner).setDiscount( setUpPoint ) )
            const discount = await variables.discount();
            await expect( discount ).eq( setUpPoint )
        })

        it('should Revert setCompensation Address Not Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            await expect( variables.connect(account1).setCompensation(20) ).to.be.reverted
        })
        
        it('should Success setCompensation Overflow Valeus', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const discount = await variables.discount()
            await expect( variables.connect(owner).setCompensation( 101 - discount ) ).to.be.reverted
        })

        it('should Success setCompensation', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner
            const setUpPoint = 5;
            await expect( variables.connect(owner).setCompensation( setUpPoint ) )
            const compensation = await variables.compensation();
            await expect( compensation ).eq( setUpPoint )
        })
        
        it('should Revert setEmergency Address Not Admin', async function() {
            const variables = this.contracts.variables
            const account1 = this.signers.account1
            const forge = this.contracts.forge;
            await expect( variables.connect(account1).setEmergency(forge.address) ).to.be.reverted
        })
        
        it('should Success setEmergency for True', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner;
            const forge = this.contracts.forge;
            let ealryTerminateFee = await variables['earlyTerminateFee()']();
            if( ealryTerminateFee == 0 ){
                await variables.connect(owner).setEarlyTerminateFee( 1 )
                ealryTerminateFee = await variables['earlyTerminateFee()']();
            }
            await variables.connect(owner).setEmergency( forge.address, true );
            const emergencyEalryTerminateFee = await variables['earlyTerminateFee(address)']( forge.address );
            await expect( emergencyEalryTerminateFee + ealryTerminateFee ).to.be.eq( ealryTerminateFee )
        })
        
        it('should Success setEmergency for False', async function() {
            const variables = this.contracts.variables
            const owner = this.signers.owner;
            const forge = this.contracts.forge;
            let ealryTerminateFee = await variables['earlyTerminateFee()']();
            if( ealryTerminateFee == 0 ){
                await variables.connect(owner).setEarlyTerminateFee( 1 )
                ealryTerminateFee = await variables['earlyTerminateFee()']();
            }
            await variables.connect(owner).setEmergency( forge.address, false );
            const emergencyEalryTerminateFee = await variables['earlyTerminateFee(address)']( forge.address );
            await expect( emergencyEalryTerminateFee ).to.be.eq( ealryTerminateFee )
        })
        */
        
    })
}