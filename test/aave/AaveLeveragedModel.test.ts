import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Signer } from "crypto";
import { BigNumber, Contract } from "ethers";
import { ethers, upgrades } from "hardhat";

import { router, token } from "../../src/config/mainnet.json";
import {
  advanceHours,
  formatValue,
  impersonate,
  deployContract,
  deployContractUpgradeable,
  deployContractUpgradeableWithLib,
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

  const FORGE_TOKEN_NAME = "Punk Finance";
  const FORGE_TOKEN_SYMBOL = "FORGE";

  before(async () => {
    underlying = await ethers.getContractAt("ERC20", token.dai);

    console.log(underlying.address);

    [deployer, governance, farmer] = await ethers.getSigners();

    console.log("Deployer", deployer.address);
    console.log("Governance", governance.address);

    const underlyingWhaleAddress = "0xF39d30Fa570db7940e5b3A3e42694665A1449E4B";
    await impersonate(underlyingWhaleAddress);
    const underlyingWhale = await ethers.getSigner(underlyingWhaleAddress);

    // Transfer underlying from whale to farmer
    await underlying
      .connect(underlyingWhale)
      .transfer(
        farmer.address,
        await underlying.balanceOf(underlyingWhaleAddress)
      );

    let farmerBalance: BigNumber;
    farmerBalance = await underlying.balanceOf(farmer.address);
    console.log(
      "Money to be made of",
      await formatValue(underlying, farmerBalance)
    );

    const forgeStorage = await deployContractUpgradeable({
      name: "Ownable",
      from: governance,
      args: [governance.address],
    });

    console.log("Forge storage", forgeStorage.address);

    const variablesStorage = await deployContractUpgradeable({
      name: "Ownable",
      from: governance,
      args: [governance.address],
    });

    console.log("Variables storage", variablesStorage.address);

    const commitmentWeight = await deployContract({
      name: "CommitmentWeight",
      from: governance,
    });
    // const commitmentWeight = await CommitmentWeight.deploy();
    // await commitmentWeight.deployed();

    console.log("Commitment Weight", commitmentWeight.address);

    const Score = await ethers.getContractFactory("Score", {
      signer: governance,
      libraries: {
        CommitmentWeight: commitmentWeight.address,
      },
    });
    const score = await Score.deploy();
    await score.deployed();

    console.log("Score", score.address);

    // Set up protocol
    forge = await deployContractUpgradeableWithLib({
      name: "Forge",
      factoryOptions: {
        signer: governance,
        libraries: { Score: score.address },
      },
      args: [
        forgeStorage,
        variablesStorage,
        FORGE_TOKEN_NAME,
        FORGE_TOKEN_SYMBOL,
        underlying,
        underlying.decimals(),
      ],
    });

    console.log(forge.address);

    // const model = await deployContractUpgradeable({
    //   name: "AaveModel",
    //   from: governance,
    //   args: [forge.address, underlying, router.uniswap],
    // });
  });

  it("farmer earns money", async () => {
    const initialFarmerBalance: BigNumber = await underlying.balanceOf(
      farmer.address
    );
    console.log(farmer.address);
    // await underlying
    //   .connect(farmer)
    //   .approve(forge.address, initialFarmerBalance);
    // await forge.connect(farmer).deposit(initialFarmerBalance, farmer.address);
    // let oldSharePrice: BigNumber;
    // let newSharePrice: BigNumber;
    // for (let i = 0; i < 10; i++) {
    //   console.log(`Loop ${i}`);
    // }
  });
});
