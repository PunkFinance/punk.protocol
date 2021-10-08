import { expect } from "chai";

export function setUpBehavior(): void {
    context("SetUp", function() {

        it('should Check Admin Addres is Timelock', async function() {
            const timelock = this.contracts.timelock
            const ownableStorage = this.contracts.ownableStorage
            await expect(await ownableStorage.isAdmin(timelock.address)).to.be.eq(true)
        })
    })
    
}