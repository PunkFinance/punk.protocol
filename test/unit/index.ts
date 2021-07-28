import { solidity } from "ethereum-waffle";
import { baseContext } from "../shared/contexts"
import { unitTestForge } from "./forge/Forge"
import { unitTestScore } from "./Score/Score"
import {use} from 'chai';

use(solidity);

baseContext("Uint Tests", function() {
    unitTestForge();
    unitTestScore();
})