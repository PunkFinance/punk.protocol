import { BigNumber } from "@ethersproject/bignumber"
import { Zero } from "@ethersproject/constants"
import { expect } from "chai"

export default function shouldBehaveLikeSetModel(): void {
    context("when setModel called with contract address", function() {
        beforeEach(async function() {
        })
        
        it("setModel", async function() {
            console.log('result', this.signers.account0.address)
            const result: boolean = await this.contracts.forge.connect(this.signers.account0).setModel(this.signers.account0.address)
            expect(result).to.be.true;
        })
    })
}