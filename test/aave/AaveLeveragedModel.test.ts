import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "crypto";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

import { router, token } from "../../src/config/mainnet.json";
import {
  advanceHours,
  formatValue,
  impersonate,
  deployContract,
  deployContractUpgradeable,
} from "../../src/utils/index";

const MODEL = "AaveLeveraged_DAI";

describe(MODEL, function () {
  this.timeout(600000);

  let underlying: Contract;

  let forge: Contract;
  let model: Contract;

  let deployer: SignerWithAddress;
  let governance: SignerWithAddress;
  let farmer: SignerWithAddress;

  before(async () => {
    underlying = await ethers.getContractAt("ERC20", token.dai);

    [deployer, governance, farmer] = await ethers.getSigners();

    const underlyingWhaleAddress = "0xF39d30Fa570db7940e5b3A3e42694665A1449E4B";
    await impersonate(underlyingWhaleAddress);

    // Transfer underlying from whale to farmer
    await underlying
      .connect(underlyingWhaleAddress)
      .transfer(
        farmer.address,
        await underlying.balanceOf(underlyingWhaleAddress)
      );

    // Set up protocol
    const protocolContracts = await setupProtocolWithModel(deployer, {
      governance,
      modelName: MODEL,
    });
  });
});
