import { unitFixtureForge } from "../../shared/fixtures"
import { shouldBehaveLikeForge } from "./Forge.behavior"

export function unitTestForge(): void {
    describe("Forge", function() {
        beforeEach(async function() {
            const forge = await this.loadFixture(unitFixtureForge)
            this.contracts.forge = forge;
        })
        shouldBehaveLikeForge()
    })
}