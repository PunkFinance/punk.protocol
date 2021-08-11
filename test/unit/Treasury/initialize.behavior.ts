import { Tokens, UniswapAddresses } from "../../shared/mockInfo"
import { expect } from "chai";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Treasury Initialize', async function() {
            const treasury = this.contracts.treasury;
            const ownableStorage = this.contracts.ownableStorage;
            const punkMock = this.contracts.punkMock;
            const grinder = this.contracts.grinder;

            await expect(treasury['initialize(address,address,address,address)'](ownableStorage.address, grinder.address, punkMock.address, UniswapAddresses.UniswapV2Router02 )).emit(treasury, "Initialize")
        })

        it('should revert Already initialized Treasury', async function() {
            const treasury = this.contracts.treasury;
            const ownableStorage = this.contracts.ownableStorage;
            const punkMock = this.contracts.punkMock;
            const grinder = this.contracts.grinder;

            await expect(treasury['initialize(address,address,address,address)'](ownableStorage.address, grinder.address, punkMock.address, UniswapAddresses.UniswapV2Router02 )).to.be.reverted
        })

    })
}