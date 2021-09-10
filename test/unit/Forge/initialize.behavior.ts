import { Tokens } from "../../shared/mockInfo"
import { expect } from "chai";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Forge Initialize', async function() {
            const forge = this.contracts.forge;
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;

            await expect(forge.initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                Tokens.Dai,
                18
            )).emit(forge, "Initialize")
        })

        it('should Revert Forge Initialize', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;

            await expect(this.contracts.forge.connect(this.signers.owner).initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                Tokens.Dai,
                18
            )).to.be.reverted
        })

        it('should Revert Forge setModel Not Admin or Gov', async function() {
            const forge = this.contracts.forge;
            const compoundModel = this.contracts.compoundModel;
            const account = this.signers.account1;
            await expect(forge.connect(account).requestUpgradeModel(compoundModel.address)).to.be.reverted
        })

        it('should Revert Forge setModel address zero', async function() {
            const forge = this.contracts.forge;
            const owner = this.signers.owner;
            await expect(forge.connect(owner).requestUpgradeModel("0x0000000000000000000000000000000000000000")).to.be.reverted
        })

        it('should Revert Forge setModel address EOA', async function() {
            const forge = this.contracts.forge;
            const owner = this.signers.owner;
            await expect(forge.connect(owner).requestUpgradeModel(owner.address)).to.be.reverted
        })

        it('should Success Forge setModel', async function() {
            const forge = this.contracts.forge;
            const compoundModel = this.contracts.compoundModel;
            const owner = this.signers.owner;
            await expect(forge.connect(owner).requestUpgradeModel(compoundModel.address)).emit(forge, "SetModel").withArgs("0x0000000000000000000000000000000000000000", compoundModel.address);
        })

    })
}