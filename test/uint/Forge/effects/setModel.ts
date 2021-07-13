import { BigNumber } from "@ethersproject/bignumber"
import { Zero } from "@ethersproject/constants"
import { expect } from "chai"

import { ForgeErrors } from '../../../shared/errors'
import { Tokens, CompoundAddresses, UniswapAddresses } from '../../../shared/mockInfo'
const name = "test"
const symbol = "TSB"

export default function shouldBehaveLikeSetModel(): void {
    context("when setModel called with contract address", function() {
        
        it("setModel with non-contract address", async function() {
            await expect(
                this.contracts.forge.connect(this.signers.owner).setModel(this.signers.account1.address),
            ).to.be.reverted
        })

        it("setModel with nonAdmin, nonGovernance address", async function() {
            await expect(
                this.contracts.forge.connect(this.signers.account0).setModel(this.contracts.compoundModel.address)
            ).to.be.reverted
        })

        it("setModel with admin address", async function() {
            // await expect(this.contracts.forge.connect(this.signers.owner).setModel(this.contracts.forge.address))
            //     .to.emit(this.contracts.forge, 'SetModel')
            //     .withArgs(this.contracts.compoundModel.address, this.contracts.compoundModel.address)
        })
    })
}