import { expect } from "chai";
import { Tokens, YearnAddresses, UniswapAddresses } from "../../../shared/mockInfo"

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success initialize', async function() {
            const yearnModel = this.contracts.YearnModel
            await expect(yearnModel.initialize(
                YearnAddresses.yvUSDC,
                this.signers.owner.address,
                YearnAddresses.USDC
            )).emit(yearnModel, "Initialize")
        })

        it('should revert Already initialized', async function() {
            const yearnModel = this.contracts.YearnModel
            await expect(yearnModel.initialize(
                YearnAddresses.yvUSDC,
                this.signers.owner,
                YearnAddresses.USDC
            )).to.be.reverted
        })

    })
}