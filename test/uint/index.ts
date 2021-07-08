import { baseContext } from "../shared/contexts"
import { unitTestForge } from "./forge/Forge"

baseContext("Uint Tests", function() {
    unitTestForge();
})