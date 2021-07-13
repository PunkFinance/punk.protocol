import { unitFixtureCompoundModel, unitFixtureDaiToken, unitFixtureForge, unitFixtureUniswapV2, unitFixtureVariables } from "../../shared/fixtures"
import { shouldBehaveLikeForge } from "./Forge.behavior"
import { Tokens, CompoundAddresses, UniswapAddresses } from '../../shared/mockInfo'
import shouldBehaveLikeCraftingSaver from "./effects/craftingSaver"

const name = "test"
const symbol = "TSB"

export function unitTestForge(): void {
    describe("Forge", function() {
        beforeEach(async function() {
            const forge = await this.loadFixture(unitFixtureForge)
            const variables = await this.loadFixture(unitFixtureVariables)
            const compoundModel = await this.loadFixture(unitFixtureCompoundModel)
            const uniswapV2Router = await this.loadFixture(unitFixtureUniswapV2)
            const daiContract = await this.loadFixture(unitFixtureDaiToken)
            this.contracts.forge = forge;
            this.contracts.variables = variables;
            this.contracts.compoundModel = compoundModel
            this.contracts.uniswapV2Router = uniswapV2Router
            this.contracts.daiContract = daiContract

            await this.contracts.compoundModel.initialize(
                this.contracts.forge.address,
                Tokens.Dai,
                CompoundAddresses.cETH,
                CompoundAddresses.COMP,
                CompoundAddresses.Comptroller,
                UniswapAddresses.UniswapV2Router02
            )
            await this.contracts.forge.initializeForge(
                this.signers.owner.address,
                this.contracts.variables.address,
                name,
                symbol,
                this.contracts.compoundModel.address,
                Tokens.Dai,
                18
            )
        })
        shouldBehaveLikeForge()
        shouldBehaveLikeCraftingSaver()
    })
}