import {
  unitPunkMockFixtures,
  unitFixtureCompoundModel,
  unitFixtureDaiToken,
  unitFixtureForge,
  unitFixtureForge2nd,
  unitFixtureForge3rd,
  unitFixtureOwnableStorage,
  unitFixtureUniswapV2,
  unitFixtureVariables,
  unitFixturePunkRewardPool,
  unitFixtureTreasury,
  unitFixtureOpTreasury,
  unitFixtureRecoveryFund,
  unitFixtureUniswapFactoryV2,
} from "../shared/fixtures";

export function beforeBehavior(): void {
  before(async function () {
    this.contracts = {
      punkMock: await this.loadFixture(unitPunkMockFixtures),
      ownableStorage: await this.loadFixture(unitFixtureOwnableStorage),
      variables: await this.loadFixture(unitFixtureVariables),
      forge: await this.loadFixture(unitFixtureForge),
      forge2: await this.loadFixture(unitFixtureForge2nd),
      forge3: await this.loadFixture(unitFixtureForge3rd),
      compoundModel: await this.loadFixture(unitFixtureCompoundModel),
      compoundModel2: await this.loadFixture(unitFixtureCompoundModel),
      compoundModel3: await this.loadFixture(unitFixtureCompoundModel),
      uniswapV2Router: await this.loadFixture(unitFixtureUniswapV2),
      daiContract: await this.loadFixture(unitFixtureDaiToken),
      rewardPool: await this.loadFixture(unitFixturePunkRewardPool),
      treasury: await this.loadFixture(unitFixtureTreasury),
      opTreasury: await this.loadFixture(unitFixtureOpTreasury),
      grinder: await this.loadFixture(unitFixtureOpTreasury),
      recoveryFundMock: await this.loadFixture(unitFixtureRecoveryFund),
      uniswapV2Factory:await this.loadFixture(unitFixtureUniswapFactoryV2)
    };

    await this.contracts.uniswapV2Factory.createPair(
      this.contracts.punkMock.address,
      await this.contracts.uniswapV2Router.WETH()
    );
  });
}
