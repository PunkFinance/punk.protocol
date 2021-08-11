import { expect } from "chai";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Variables Initialize', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            await expect(variables.initialize(ownableStorage.address)).emit(variables, "Initialize")
        })

        it('should revert Aready initialized Variables', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            await expect(variables.initialize(ownableStorage.address)).to.be.reverted
        })

    })
}