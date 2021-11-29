const { expect } = require("chai");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();
    const txParams = { from: owner };
    const Token = await ethers.getContractFactory("BitcoinnamiIDO");

    const hardhatToken = await Token.deploy(owner, owner, txParams);

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});