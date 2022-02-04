import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"


export function unitTestTreasury(): void {
    describe("Treasury", function() {
        initialBehavior()
        setUpBehavior()
    })

}