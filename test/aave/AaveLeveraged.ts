import {
  unitFixtureAaveModel,
  unitFixtureCompoundModel,
  unitFixtureDaiToken,
  unitFixtureForge,
  unitFixtureOwnableStorage,
  unitFixtureUniswapV2,
  unitFixtureVariables,
} from "../shared/fixtures";
import {
  Tokens,
  CompoundAddresses,
  UniswapAddresses,
} from "../shared/mockInfo";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers, upgrades } from "hardhat";
import { formatValue, impersonate } from "../../src/utils/index";
import { BigNumber, Contract } from "ethers";

const name = "test";
const symbol = "TSB";

export function unitTestAaveModel(): void {
  describe("AaveLeveraged", function () {
    before(async function () {
      const forge = await this.loadFixture(unitFixtureForge);
      const variables = await this.loadFixture(unitFixtureVariables);
      const aaveModel = await this.loadFixture(unitFixtureAaveModel);
      const uniswapV2Router = await this.loadFixture(unitFixtureUniswapV2);
      const daiContract = await this.loadFixture(unitFixtureDaiToken);
      const ownableStorage = await this.loadFixture(unitFixtureOwnableStorage);

      this.contracts.forge = forge;
      this.contracts.variables = variables;
      this.contracts.aaveModel = aaveModel;
      this.contracts.uniswapV2Router = uniswapV2Router;
      this.contracts.daiContract = daiContract;

      await this.contracts.aaveModel.initialize(
        this.contracts.forge.address,
        Tokens.Dai,
        UniswapAddresses.UniswapV2Router02
      );
      await this.contracts.forge
        .connect(this.signers.owner)
        .initializeForge(
          ownableStorage.address,
          this.contracts.variables.address,
          name,
          symbol,
          this.contracts.aaveModel.address,
          Tokens.Dai,
          18
        );

      const underlyingWhaleAddress =
        "0xF39d30Fa570db7940e5b3A3e42694665A1449E4B";
      await impersonate(underlyingWhaleAddress);
      const underlyingWhale = await ethers.getSigner(underlyingWhaleAddress);

      await daiContract
        .connect(underlyingWhale)
        .transfer(
          this.signers.accountDai.address,
          await daiContract.balanceOf(underlyingWhaleAddress)
        );

      let farmerBalance: BigNumber;
      farmerBalance = await daiContract.balanceOf(
        this.signers.accountDai.address
      );
      console.log(
        "Money to be made of",
        await formatValue(daiContract, farmerBalance)
      );
    });
  });
}
