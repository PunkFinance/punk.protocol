import shouldEarnMoney from "./effects/earnMoney";

export function shouldBehaveLikeAaveModel(): void {
  describe("earnMoney", function () {
    shouldEarnMoney();
  });
}
