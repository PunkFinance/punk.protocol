import { Tokens } from "../../shared/mockInfo"
import { expect } from "chai";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Forge Initialize with CompoundModel', async function() {
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

        it('should Revert Forge Initialize with CompoundModel', async function() {
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
        
        it('should Success Forge Initialize with YearnModel', async function() {
            const forgeYearn = this.contracts.forgeYearn;
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            const yearnModel = this.contracts.Yearnmodel;

            await expect(forgeYearn.initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                yearnModel.address,
                Tokens.Dai,
                18
            )).emit(forgeYearn, "Initialize")
        })

        it('should Revert Forge Initialize with YearnModel', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            const yearnModel = this.contracts.YearnModel;

            await expect(this.contracts.forgeYearn.connect(this.signers.owner).initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                yearnModel.address,
                Tokens.Dai,
                18
            )).to.be.reverted
        })

    })
}