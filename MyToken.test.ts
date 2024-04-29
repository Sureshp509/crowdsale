// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ethers } from "hardhat";
import { expect } from "chai";

describe("MyToken", function () {
    let MyToken;
    let myToken;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        MyToken = await ethers.getContractFactory("MyToken");
        [owner, addr1, addr2] = await ethers.getSigners();
        myToken = await MyToken.deploy("MyToken", "MTK", 18, ethers.utils.parseEther("1000000"));
        await myToken.deployed();
    });

    it("Should have correct initial values", async function () {
        expect(await myToken.name()).to.equal("MyToken");
        expect(await myToken.symbol()).to.equal("MTK");
        expect(await myToken.decimals()).to.equal(18);
        expect(await myToken.totalSupply()).to.equal(ethers.utils.parseEther("1000000"));
    });

    it("Should transfer tokens between accounts", async function () {
        await myToken.transfer(addr1.address, ethers.utils.parseEther("1000"));
        expect(await myToken.balanceOf(addr1.address)).to.equal(ethers.utils.parseEther("1000"));

        await myToken.connect(addr1).transfer(addr2.address, ethers.utils.parseEther("500"));
        expect(await myToken.balanceOf(addr2.address)).to.equal(ethers.utils.parseEther("500"));
    });
});
