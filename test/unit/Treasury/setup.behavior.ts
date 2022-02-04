import { Tokens } from "../../shared/mockInfo";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { abiEncode, ethToWei } from "../../shared/utils";

export function setUpBehavior(): void {
  context("SetUp", function () {

    before(async function(){
        const recoveryFundMock = this.contracts.recoveryFundMock;
        const uniswapV2Router = this.contracts.uniswapV2Router
        const accountDai = this.signers.accountDai
        
        const blockNumber = await ethers.provider.getBlockNumber()
        const blockInfo = await ethers.provider.getBlock(blockNumber)

        const swapResult = await uniswapV2Router.connect(accountDai).swapExactETHForTokens(
            1,
            [Tokens.WETH, Tokens.Dai],
            recoveryFundMock.address,
            blockInfo.timestamp + 25*60*60,
            {value: ethToWei("700"), gasLimit: '2600000'}
        )
        await swapResult.wait()
    })

    it("should Revert addAsset Address Not Admin", async function () {
      const treasury = this.contracts.treasury;
      const account1 = this.signers.account1;
      await expect(
        treasury.connect(account1).addAsset(Tokens.Dai)
      ).to.be.reverted;
    });

    it("should Success addAsset", async function () {
      const treasury = this.contracts.treasury;
      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
    
      const data = abiEncode(["address"], [Tokens.Dai]);
      await timelock.queueTransaction(
        treasury.address,
        0,
        "addAsset(address)",
        data,
        eta
      );

      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");

      await expect(timelock.executeTransaction(
        treasury.address,
        0,
        "addAsset(address)",
        data,
        eta
      )).emit(treasury, "AddAsset").withArgs(Tokens.Dai);
    });

    it("should Revert addAsset Already Registry Token", async function () {
      const treasury = this.contracts.treasury;
      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
    
      const data = abiEncode(["address"], [Tokens.Dai]);
      await timelock.queueTransaction(
        treasury.address,
        0,
        "addAsset(address)",
        data,
        eta
      );

      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");

      await expect(timelock.executeTransaction(
        treasury.address,
        0,
        "addAsset(address)",
        data,
        eta
      )).to.be.reverted;
    });

    it("should Revert addAsset Buyback Test", async function () {
      const treasury = this.contracts.treasury;
      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
      
      const daiContract = this.contracts.daiContract;
      const accountDai = this.signers.accountDai

      await daiContract.connect(accountDai).transfer(treasury.address, ethToWei("10"));

      const data = abiEncode(["address[]", "uint256[]"], [[accountDai.address],[1]]);
      await timelock.queueTransaction(
        treasury.address,
        0,
        "buyBack(address[],uint256[])",
        data,
        eta
      );

      await network.provider.send("evm_increaseTime", [49 * 60 * 60 + 20]);
      await network.provider.send("evm_mine");

      await timelock.executeTransaction(
        treasury.address,
        0,
        "buyBack(address[],uint256[])",
        data,
        eta
      )

    });
  });
}
