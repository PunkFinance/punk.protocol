import { Tokens } from "../../shared/mockInfo"
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { keccak256 } from "@ethersproject/keccak256";
import { abiEncode } from "../../shared/utils";

export function initialBehavior(): void {
    context("Initailize", function() {

        it('should Success Forge Initialize', async function() {
            const forge = this.contracts.forge;
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;
            const compoundModel = this.contracts.compoundModel;

            await expect(forge.initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                compoundModel.address,
                Tokens.Dai,
                18
            )).emit(forge, "Initialize")
        })

        it('should Revert Forge Initialize', async function() {
            const ownableStorage = this.contracts.ownableStorage;
            const variables = this.contracts.variables;

            await expect(this.contracts.forge.connect(this.signers.owner).initializeForge(
                ownableStorage.address,
                variables.address,
                "Punk-Forge-DAI-0",
                "pDAI",
                Tokens.Dai,
                18
            )).to.be.reverted
        })

        it('should Revert Forge upgradeModel Not Admin', async function() {
            const forge = this.contracts.forge;
            const compoundModel = this.contracts.compoundModel;
            const account = this.signers.account1;
            await expect(forge.connect(account).upgradeModel(compoundModel.address)).to.be.reverted
        })

        let eta = 0;
        it('should Revert Forge upgradeModel address zero', async function() {
            const forge = this.contracts.forge;
            const timelock = this.contracts.timelock;
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            eta = blockInfo.timestamp + 49 * 60 * 60

            const data = abiEncode(['address'],["0x0000000000000000000000000000000000000000"] );
            const txHash = keccak256(abiEncode( ['address', 'uint', 'string', 'bytes', 'uint'], [forge.address, 0, "upgradeModel(address)", data, eta] ))
            
            await timelock.queueTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )
            
            await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true)

            await network.provider.send("evm_increaseTime", [49*60*60]);
            await network.provider.send("evm_mine")

            await expect(timelock.executeTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )).to.be.reverted
        })

        it('should Revert Forge setModel address EOA', async function() {
            const account = this.signers.owner;

            const forge = this.contracts.forge;
            const timelock = this.contracts.timelock;
            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            eta = blockInfo.timestamp + 49 * 60 * 60

            const data = abiEncode(['address'],[account.address] );
            const txHash = keccak256(abiEncode( ['address', 'uint', 'string', 'bytes', 'uint'], [forge.address, 0, "upgradeModel(address)", data, eta] ))
            
            await timelock.queueTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )
            
            await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true)

            await network.provider.send("evm_increaseTime", [49*60*60]);
            await network.provider.send("evm_mine")

            await expect(timelock.executeTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )).to.be.reverted
        })

        it('should Success Forge setModel', async function() {
            const model = this.contracts.compoundModelToReplaced;
            const forge = this.contracts.forge;
            const timelock = this.contracts.timelock;

            const blockNumber = await ethers.provider.getBlockNumber()
            const blockInfo = await ethers.provider.getBlock(blockNumber)
            eta = blockInfo.timestamp + 49 * 60 * 60

            const data = abiEncode(['address'],[model.address] );
            const txHash = keccak256(abiEncode( ['address', 'uint', 'string', 'bytes', 'uint'], [forge.address, 0, "upgradeModel(address)", data, eta] ))
            
            await timelock.queueTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )
            
            await expect(await timelock.queuedTransactions(txHash)).to.be.eq(true)

            await network.provider.send("evm_increaseTime", [49*60*60]);
            await network.provider.send("evm_mine")

            await timelock.executeTransaction(
                forge.address,
                0,
                "upgradeModel(address)",
                data,
                eta
            )

            await expect( await forge.modelAddress() ).to.be.eq(model.address)
        })

    })
}