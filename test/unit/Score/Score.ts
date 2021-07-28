import { unitFixtureScoreMock } from "../../shared/fixtures"
import { ScoreMock } from '../../../typechain'
import { expect } from "chai"
export function unitTestScore(): void {
    describe("Score", function() {
        before(async function() {
            const scoreMock: ScoreMock = await this.loadFixture(unitFixtureScoreMock)
            this.contracts.scoreMock = scoreMock; 
        })

        context("Score model test", function() {
            it("Calculate score correctly", async function() {
                const createTimestamp = 1622520000 // 2021-06-01 00:00:00
                const startTimestamp = 1638334800 // 2021-12-01 00:00:00
                const count = 1;
                const interval = 1;
                const transactions = [
                    { 
                        timestamp:1622520000,
                        amount:100000,
                        pos: true,
                    },
                    { 
                        timestamp:1622520000,
                        amount:100000, 
                        pos: true,
                    },
                    { 
                        timestamp:1622520000,
                        amount:100000,
                        pos: true,
                    } 
                ];

                const scoreResult = await this.contracts.scoreMock.scoreCalculation(
                    createTimestamp,
                    startTimestamp,
                    transactions,
                    count,
                    interval,
                    18
                )
                
                await expect(scoreResult).to.be.equal(480)
            })
        })
    })
}