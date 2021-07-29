import { unitFixtureCompoundModel, unitFixtureDaiToken, unitFixtureForge, unitFixtureOwnableStorage, unitFixtureUniswapV2, unitFixtureVariables, unitFixtureReferral, unitFixturePunkRewardPool } from "../../shared/fixtures"
import { Tokens, CompoundAddresses, UniswapAddresses } from '../../shared/mockInfo'
import shouldBehaveLikeCraftingSaver from "./effects/craftingSaver"

const name = "test"
const symbol = "TSB"

export function unitTestForge(): void {
    describe("Forge", function() {
        before(async function() {
            const forge = await this.loadFixture(unitFixtureForge)
            const variables = await this.loadFixture(unitFixtureVariables)
            const compoundModel = await this.loadFixture(unitFixtureCompoundModel)
            const uniswapV2Router = await this.loadFixture(unitFixtureUniswapV2)
            const daiContract = await this.loadFixture(unitFixtureDaiToken)
            const ownableStorage = await this.loadFixture(unitFixtureOwnableStorage)
            const referral = await this.loadFixture(unitFixtureReferral)
            const rewardPool = await this.loadFixture(unitFixturePunkRewardPool)
            

            this.contracts.forge = forge;
            this.contracts.variables = variables;
            this.contracts.compoundModel = compoundModel
            this.contracts.uniswapV2Router = uniswapV2Router
            this.contracts.daiContract = daiContract
            
            this.contracts.referral = referral
            this.contracts.rewardPool = rewardPool

            await this.contracts.variables.connect(this.signers.owner).initializeVariables(ownableStorage.address);
            await this.contracts.variables.connect(this.signers.owner).setReferral(referral.address);
            await this.contracts.variables.connect(this.signers.owner).setTreasury("0x4722AE29673D4A978a7bb15b5247a8734FAEfd94");
            await this.contracts.variables.connect(this.signers.owner).setOpTreasury("0x4722AE29673D4A978a7bb15b5247a8734FAEfd94");
            await this.contracts.variables.connect(this.signers.owner).setReward(rewardPool.address);
            
            await this.contracts.rewardPool.connect(this.signers.owner).initializePunkReward( ownableStorage.address, "0x6b175474e89094c44da98b954eedeac495271d0f" );
            await this.contracts.rewardPool.connect(this.signers.owner).addForge( this.contracts.forge.address );

            await this.contracts.compoundModel.initialize(
                this.contracts.forge.address,
                Tokens.Dai,
                CompoundAddresses.cDai,
                CompoundAddresses.COMP,
                CompoundAddresses.Comptroller,
                UniswapAddresses.UniswapV2Router02
            )
            await this.contracts.forge.connect(this.signers.owner).initializeForge(
                ownableStorage.address,
                this.contracts.variables.address,
                name,
                symbol,
                this.contracts.compoundModel.address,
                Tokens.Dai,
                18
            )

        })
        // shouldBehaveLikeForge()
        shouldBehaveLikeCraftingSaver()
    })
}