import { Tokens } from "../../shared/mockInfo"
import { expect } from "chai";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Forge Initialize', async function() {
            const forge = this.contracts.forge;
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            const compoundModel = this.contracts.compoundModel;

            await expect(forge.initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                compoundModel.address,
                Tokens.Dai,
                18
            )).emit(forge, "Initialize")
        })

        it('should Revert Forge Initialize', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            const compoundModel = this.contracts.compoundModel;

            await expect(this.contracts.forge.connect(this.signers.owner).initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                compoundModel.address,
                Tokens.Dai,
                18
            )).to.be.reverted
        })

    })
}