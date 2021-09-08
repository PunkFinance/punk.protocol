import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"

export function unitTestYearnModel(): void {
    describe("YearnModel", function() {
        initialBehavior()
        setUpBehavior()
    })
}