import { initialBehavior } from "./initialize.behavior"
import { saverBehavior } from "./saver.behavior"

export function unitTestForge(): void {
    describe("Forge", function() {
        initialBehavior()
        saverBehavior()
    })

}