import { unitFixtureCompoundModel, unitFixtureDaiToken, unitFixtureForge, unitFixtureOwnableStorage, unitFixtureUniswapV2, unitFixtureVariables } from "../../shared/fixtures"
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

            this.contracts.forge = forge;
            this.contracts.variables = variables;
            this.contracts.compoundModel = compoundModel
            this.contracts.uniswapV2Router = uniswapV2Router
            this.contracts.daiContract = daiContract

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