import { BigNumber } from "@ethersproject/bignumber"
import { Zero } from "@ethersproject/constants"
import { expect } from "chai"

import { ForgeErrors } from '../../../shared/errors'

export default function shouldBehaveLikeSetModel(): void {
    context("when setModel called with contract address", function() {
        beforeEach(async function() {
            
        })
        
        it("setModel with non-contract address", async function() {
            await expect(
                this.contracts.forge.connect(this.signers.account0).setModel(this.signers.account0.address),
            ).to.be.revertedWith(ForgeErrors.NotContract)
        })

        it("setModel with contract address", async function() {
            
        })
    })
}