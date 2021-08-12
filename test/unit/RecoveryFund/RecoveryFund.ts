import { initialBehavior } from "./initialize.behavior"
import { setUpBehavior } from "./setup.behavior"


export function unitTestRecoveryFund(): void {
    
    describe("RecoveryFundMock", function() {
        initialBehavior()
        setUpBehavior()
    })

}