import { BigNumber } from "@ethersproject/bignumber"
import { Zero } from "@ethersproject/constants"
import { expect } from "chai"

import { ForgeErrors } from '../../../shared/errors'
import { Tokens, CompoundAddresses, UniswapAddresses } from '../../../shared/mockInfo'
const name = "test"
const symbol = "TSB"

export default function shouldBehaveLikeSetModel(): void {
    context("when setModel called with contract address", function() {
        beforeEach(async function() {
            await this.contracts.compoundModel.initialize(
                this.contracts.forge.address,
                Tokens.Dai,
                CompoundAddresses.cETH,
                CompoundAddresses.COMP,
                CompoundAddresses.Comptroller,
                UniswapAddresses.UniswapV2Router02
            )
            await this.contracts.forge.initializeForge(
                this.signers.owner.address,
                this.contracts.variables.address,
                name,
                symbol,
                this.contracts.compoundModel.address,
                Tokens.Dai,
                18
            )

        })
        
        it("setModel with non-contract address", async function() {
            await expect(
                this.contracts.forge.connect(this.signers.owner).setModel(this.signers.account0.address),
            ).to.be.reverted
        })

        it("setModel with nonAdmin, nonGovernance address", async function() {
            await expect(
                this.contracts.forge.connect(this.signers.account0).setModel(this.contracts.compoundModel.address)
            ).to.be.reverted
        })

        it("setModel with admin address", async function() {
            // await expect(
            //     this.contracts.forge.connect(this.signers.owner).callStatic.setModel(this.contracts.compoundModel.address)
            // ).to.be.true
        })
    })
}