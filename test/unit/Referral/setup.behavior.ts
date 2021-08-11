import { expect } from "chai";

export function setUpBehavior(): void {
    context("SetUp", function() {

        it('should Success Issue ReferralCode & Revert Already Issue', async function() {
            const referral = this.contracts.referral
            const account1 = this.signers.account1
            await referral.issue(account1.address);
            await expect( referral.issue(account1.address) ).to.be.reverted
        })

        it('should Check & Validate', async function() {
            const referral = this.contracts.referral
            const account1 = this.signers.account1
            const address = await referral.referralCode( account1.address );
            await expect( await referral.validate( address ) ).to.be.eq( account1.address )
        })

    })
    
}