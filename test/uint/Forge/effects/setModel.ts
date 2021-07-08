import { BigNumber } from "@ethersproject/bignumber"
import { Zero } from "@ethersproject/constants"
import { expect } from "chai"

export default function shouldBehaveLikeSetModel(): void {
    context("when setModel called with contract address", function() {
        this.beforeEach(async function() {
            this.contracts.Forge.connect()
        })
    })
}