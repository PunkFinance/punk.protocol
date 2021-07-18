import shouldBehaveLikeSetModel from "./effects/setModel";

export function shouldBehaveLikeForge(): void {
    describe("setModel", function() {
        shouldBehaveLikeSetModel()
    })
}