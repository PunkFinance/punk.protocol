import { unitFixtureCompoundModel, unitFixtureForge, unitFixtureVariables } from "../../shared/fixtures"
import { shouldBehaveLikeForge } from "./Forge.behavior"

export function unitTestForge(): void {
    describe("Forge", function() {
        beforeEach(async function() {
            const forge = await this.loadFixture(unitFixtureForge)
            const variables = await this.loadFixture(unitFixtureVariables)
            const compoundModel = await this.loadFixture(unitFixtureCompoundModel)
            this.contracts.forge = forge;
            this.contracts.variables = variables;
            this.contracts.compoundModel = compoundModel
        })
        shouldBehaveLikeForge()
    })
}