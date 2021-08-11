import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"


export function unitTestVariables(): void {
    describe("Variables", function() {
        
        initialBehavior()

        setUpBehavior()
    })

}