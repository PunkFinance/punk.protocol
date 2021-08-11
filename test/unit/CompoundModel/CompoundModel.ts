import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"

export function unitTestCompoundModel(): void {
    describe("CompoundModel", function() {
        initialBehavior()
        setUpBehavior()
    })
}