import { keccak256 } from "@ethersproject/keccak256";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { abiEncode } from "../../shared/utils";

export function setUpBehavior(): void {
  context("SetUp", function () {
    // let etaSetReward = 0;

    // it("should Success addQueue setReward Address", async function () {
    //   const variables = this.contracts.variables;
    //   const rewardPool = this.contracts.rewardPool;
    //   const timelock = this.contracts.timelock;
    //   const blockNumber = await ethers.provider.getBlockNumber()
    //   const blockInfo = await ethers.provider.getBlock(blockNumber)
    //   const eta = blockInfo.timestamp + 49 * 60 * 60
    //   etaSetReward = eta;

    //   const data = abiEncode(['address'],[rewardPool.address] );
    //   const txHash = keccak256(abiEncode( ['address', 'uint', 'string', 'bytes', 'uint'], [variables.address, 0, "setReward(address)", data, etaSetReward] ))

    //   await timelock.queueTransaction(
    //     variables.address,
    //     0,
    //     "setReward(address)",
    //     data,
    //     etaSetReward
    //   )

    //   await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true)
    // });

    // it("should Revert executeTx setReward", async function () {
    //   const variables = this.contracts.variables;
    //   const rewardPool = this.contracts.rewardPool;
    //   const timelock = this.contracts.timelock;
    //   const data = abiEncode(['address'],[rewardPool.address] );

    //   await expect(timelock.executeTransaction(
    //     variables.address,
    //     0,
    //     "setReward(address)",
    //     data,
    //     etaSetReward
    //   )).to.be.reverted
    // });

    // it("should Success executeTx setReward", async function () {
    //   const variables = this.contracts.variables;
    //   const rewardPool = this.contracts.rewardPool;
    //   const timelock = this.contracts.timelock;
    //   const data = abiEncode(['address'],[rewardPool.address] );

    //   await network.provider.send("evm_increaseTime", [49*60*60]);
    //   await network.provider.send("evm_mine")

    //   // await expect().to.be.reverted
    //   timelock.executeTransaction(
    //     variables.address,
    //     0,
    //     "setReward(address)",
    //     data,
    //     etaSetReward
    //   )

    //   await expect( await variables.reward() ).to.be.eq(rewardPool.address)
    // });

    let etaSetSuccessFee = 0;

    it("should Success addQueue setSuccessFee", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
      etaSetSuccessFee = eta;

      const data = abiEncode(["uint256"], [10]);
      const txHash = keccak256(
        abiEncode(
          ["address", "uint", "string", "bytes", "uint"],
          [
            variables.address,
            0,
            "setSuccessFee(uint256)",
            data,
            etaSetSuccessFee,
          ]
        )
      );

      await timelock.queueTransaction(
        variables.address,
        0,
        "setSuccessFee(uint256)",
        data,
        etaSetSuccessFee
      );

      await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true);
    });

    it("should Revert executeTx setSuccessFee", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const data = abiEncode(["uint256"], [10]);

      await expect(
        timelock.executeTransaction(
          variables.address,
          0,
          "setSuccessFee(uint256)",
          data,
          etaSetSuccessFee
        )
      ).to.be.reverted;
    });

    it("should Success executeTx setSuccessFee", async function () {
      const variables = this.contracts.variables;
      const timelock = this.contracts.timelock;

      const data = abiEncode(["uint256"], [10]);
      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);

      timelock.executeTransaction(
        variables.address,
        0,
        "setSuccessFee(uint256)",
        data,
        etaSetSuccessFee
      );

      await expect(await variables.successFee()).to.be.eq(10);
    });

    let etaSetServiceFee = 0;

    it("should Success addQueue setServiceFee", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
      etaSetServiceFee = eta;

      const data = abiEncode(["uint256"], [1]);
      const txHash = keccak256(
        abiEncode(
          ["address", "uint", "string", "bytes", "uint"],
          [
            variables.address,
            0,
            "setServiceFee(uint256)",
            data,
            etaSetServiceFee,
          ]
        )
      );

      await timelock.queueTransaction(
        variables.address,
        0,
        "setServiceFee(uint256)",
        data,
        etaSetServiceFee
      );

      await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true);
    });

    it("should Revert executeTx setServiceFee", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const data = abiEncode(["uint256"], [1]);

      await expect(
        timelock.executeTransaction(
          variables.address,
          0,
          "setServiceFee(uint256)",
          data,
          etaSetServiceFee
        )
      ).to.be.reverted;
    });

    it("should Success executeTx setServiceFee", async function () {
      const variables = this.contracts.variables;
      const timelock = this.contracts.timelock;

      const data = abiEncode(["uint256"], [1]);
      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");

      timelock.executeTransaction(
        variables.address,
        0,
        "setServiceFee(uint256)",
        data,
        etaSetServiceFee
      );

      await expect(await variables.serviceFee()).to.be.eq(1);
    });

    let etaSetFeeMultiplier = 0;

    it("should Success addQueue setFeeMultiplier", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
      etaSetFeeMultiplier = eta;

      const data = abiEncode(["uint256"], [150]);
      const txHash = keccak256(
        abiEncode(
          ["address", "uint", "string", "bytes", "uint"],
          [
            variables.address,
            0,
            "setFeeMultiplier(uint256)",
            data,
            etaSetFeeMultiplier,
          ]
        )
      );

      await timelock.queueTransaction(
        variables.address,
        0,
        "setFeeMultiplier(uint256)",
        data,
        etaSetFeeMultiplier
      );

      await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true);
    });

    it("should Revert executeTx setFeeMultiplier", async function () {
      const variables = this.contracts.variables;

      const timelock = this.contracts.timelock;
      const data = abiEncode(["uint256"], [150]);

      await expect(
        timelock.executeTransaction(
          variables.address,
          0,
          "setFeeMultiplier(uint256)",
          data,
          etaSetFeeMultiplier
        )
      ).to.be.reverted;
    });

    it("should Success executeTx setFeeMultiplier", async function () {
      const variables = this.contracts.variables;
      const timelock = this.contracts.timelock;

      const data = abiEncode(["uint256"], [150]);
      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");

      timelock.executeTransaction(
        variables.address,
        0,
        "setFeeMultiplier(uint256)",
        data,
        etaSetFeeMultiplier
      );

      await expect(await variables.feeMultiplier()).to.be.eq(150);
    });

    let etaSetTreasury = 0;

    it("should Success addQueue setTreasury", async function () {
      const variables = this.contracts.variables;
      const treasury = this.contracts.treasury;

      const timelock = this.contracts.timelock;
      const blockNumber = await ethers.provider.getBlockNumber();
      const blockInfo = await ethers.provider.getBlock(blockNumber);
      const eta = blockInfo.timestamp + 49 * 60 * 60;
      etaSetTreasury = eta;

      const data = abiEncode(["address"], [treasury.address]);
      const txHash = keccak256(
        abiEncode(
          ["address", "uint", "string", "bytes", "uint"],
          [variables.address, 0, "setTreasury(address)", data, etaSetTreasury]
        )
      );

      await timelock.queueTransaction(
        variables.address,
        0,
        "setTreasury(address)",
        data,
        etaSetTreasury
      );

      await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true);
    });

    it("should Revert executeTx setTreasury", async function () {
      const variables = this.contracts.variables;
      const treasury = this.contracts.treasury;

      const timelock = this.contracts.timelock;
      const data = abiEncode(["address"], [treasury.address]);

      await expect(
        timelock.executeTransaction(
          variables.address,
          0,
          "setTreasury(address)",
          data,
          etaSetTreasury
        )
      ).to.be.reverted;
    });

    it("should Success executeTx setTreasury", async function () {
      const variables = this.contracts.variables;
      const timelock = this.contracts.timelock;
      const treasury = this.contracts.treasury;

      const data = abiEncode(["address"], [treasury.address]);
      await network.provider.send("evm_increaseTime", [49 * 60 * 60]);
      await network.provider.send("evm_mine");

      timelock.executeTransaction(
        variables.address,
        0,
        "setTreasury(address)",
        data,
        etaSetTreasury
      );

      await expect(await variables.treasury()).to.be.eq(treasury.address);
    });
  });
}
