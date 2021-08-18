import { solidity } from "ethereum-waffle";
import { baseContext } from "../shared/contexts";
import { beforeBehavior } from "./before.behavior";
import { use } from "chai";

import { unitTestOwnableStorage } from "./OwnableStorage/OwnableStorage";
import { unitTestVariables } from "./Variables/Variables";
import { unitTestTreasury } from "./Treasury/Treasury";
import { unitTestPunkRewardPool } from "./PunkRewardPool/PunkRewardPool";
import { unitTestCompoundModel } from "./CompoundModel/CompoundModel";
import { unitTestRecoveryFund } from "./RecoveryFund/RecoveryFund";
import { unitTestForge } from "./Forge/Forge";

use(solidity);

baseContext("Unit Tests", async function () {
  beforeBehavior();

  unitTestRecoveryFund();

  unitTestOwnableStorage();

  unitTestVariables();

  unitTestTreasury();

  unitTestPunkRewardPool();

  unitTestCompoundModel();

  unitTestForge();
});
