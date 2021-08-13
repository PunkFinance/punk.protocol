import { solidity } from "ethereum-waffle";
import { baseContext } from "../shared/contexts"

import { beforeBehavior } from "./before.behavior"

import { unitTestOwnableStorage } from "./OwnableStorage/OwnableStorage"
import { unitTestVariables } from "./Variables/Variables"
import { unitTestReferral } from "./Referral/Referral"
import { unitTestTreasury } from "./Treasury/Treasury"

import { unitTestPunkRewardPool } from "./PunkRewardPool/PunkRewardPool"
import { unitTestCompoundModel } from "./CompoundModel/CompoundModel"

import { unitTestRecoveryFund } from "./RecoveryFund/RecoveryFund"

import { unitTestForge } from "./Forge/Forge"
import { unitTestScore } from "./Score/Score"

import {use} from 'chai';


use(solidity);

baseContext("Unit Tests", async function() {
    
    beforeBehavior();

    unitTestRecoveryFund();
    
    unitTestOwnableStorage();
    
    unitTestVariables();
    
    unitTestReferral();

    unitTestTreasury();

    unitTestPunkRewardPool();

    unitTestCompoundModel();

    unitTestForge();

    unitTestScore();

})