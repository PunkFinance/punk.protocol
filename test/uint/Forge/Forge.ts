import { unitFixtureForge, unitFixtureVariables } from "../../shared/fixtures"
import { shouldBehaveLikeForge } from "./Forge.behavior"

export function unitTestForge(): void {
    describe("Forge", function() {
        beforeEach(async function() {
            const forge = await this.loadFixture(unitFixtureForge)
            const variables = await this.loadFixture(unitFixtureVariables)
            this.contracts.forge = forge;
            this.contracts.variables = variables;
        })
        shouldBehaveLikeForge()
    })
}