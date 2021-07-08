import { shouldBehaveLikeForge } from "./Forge.behavior"

export function unitTestForge(): void {
    describe("Forge", function() {
        beforeEach(async function() {
            shouldBehaveLikeForge()
        })
    })
}