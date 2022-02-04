import { expect } from "chai";

export function setUpBehavior(): void {
    context("SetUp", function() {

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