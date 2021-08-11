import { expect } from "chai";
import { Tokens, CompoundAddresses, UniswapAddresses } from "../../shared/mockInfo"

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success initialize', async function() {
            const compoundModel = this.contracts.compoundModel
            await expect(compoundModel.initialize(
                this.contracts.forge.address,
                Tokens.Dai,
                CompoundAddresses.cDai,
                CompoundAddresses.COMP,
                CompoundAddresses.Comptroller,
                UniswapAddresses.UniswapV2Router02
            )).emit( compoundModel, "Initialize" )
        })

        it('should revert Already initialized', async function() {
            const compoundModel = this.contracts.compoundModel
            await expect(compoundModel.initialize(
                this.contracts.forge.address,
                Tokens.Dai,
                CompoundAddresses.cDai,
                CompoundAddresses.COMP,
                CompoundAddresses.Comptroller,
                UniswapAddresses.UniswapV2Router02
            )).to.be.reverted
        })

    })
}