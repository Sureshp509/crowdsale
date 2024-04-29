// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ethers } from "hardhat";
import { expect } from "chai";

describe("Crowdsale", function () {
    let MyToken;
    let myToken;
    let Crowdsale;
    let crowdsale;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        MyToken = await ethers.getContractFactory("MyToken");
        Crowdsale = await ethers.getContractFactory("Crowdsale");

        [owner, addr1, addr2] = await ethers.getSigners();
        myToken = await MyToken.deploy("MyToken", "MTK", 18, ethers.utils.parseEther("1000000"));
        await myToken.deployed();

        crowdsale = await Crowdsale.deploy(
            myToken.address,
            100, // rate
            Math.floor(Date.now() / 1000) + 86400, // start time (24 hours from now)
            Math.floor(Date.now() / 1000) + 172800, // end time (48 hours from now)
            0, // cliff period
            0 // vesting period
        );
        await crowdsale.deployed();
    });

    it("Should start and end the sale", async function () {
        await expect(crowdsale.startSale())
            .to.emit(crowdsale, "SaleStarted")
            .withArgs(await crowdsale.startTime());

        await expect(crowdsale.endSale())
            .to.emit(crowdsale, "SaleEnded")
            .withArgs(await crowdsale.endTime());
    });

    it("Should buy tokens during the sale", async function () {
        await crowdsale.startSale();
        await expect(crowdsale.connect(addr1).buyTokens({ value: ethers.utils.parseEther("1") }))
            .to.emit(crowdsale, "TokensPurchased")
            .withArgs(addr1.address, ethers.utils.parseEther("100"), ethers.utils.parseEther("1"));
    });

    it("Should schedule and release vested tokens", async function () {
        await crowdsale.scheduleVesting(addr1.address, ethers.utils.parseEther("1000"));
        await crowdsale.releaseVestedTokens(addr1.address);
        expect(await myToken.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther("1000"));
    });
});
