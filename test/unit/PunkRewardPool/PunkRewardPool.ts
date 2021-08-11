import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"

export function unitTestPunkRewardPool(): void {
    describe("PunkRewardPool", function() {
        initialBehavior()
        setUpBehavior()
    })
}