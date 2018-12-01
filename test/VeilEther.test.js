import expectEventInTransaction from "./utils/expectEvent";
import expectThrow from "./utils/expectThrow";
import toWei from "./utils/toWei";
import { constants } from "./utils/constants";
import { advanceBlock } from "./utils/advanceToBlock";

const VeilEther = artifacts.require("VeilEther");
const BigNumber = web3.BigNumber;
const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("VeilEther", ([creator, spender, owner, randomUser]) => {
  let token;

  beforeEach(async () => {
    token = await VeilEther.new({ from: creator });
    await advanceBlock();
  });

  describe("token metadata", () => {
    it("has a name", async () => {
      const name = await token.name();
      assert.equal(name, "Veil Ether");
    });

    it("has a symbol", async () => {
      const symbol = await token.symbol();
      assert.equal(symbol, "Veil Ether");
    });

    it("has 18 decimals", async () => {
      const decimals = await token.decimals();
      assert(decimals.eq(18));
    });
  });

  describe("depositAndApprove", () => {
    it("deposits and sets the correct Veil Ether balance", async () => {
      const initialBalance = await token.balanceOf(owner);
      initialBalance.should.be.bignumber.equal(0);

      await expectEventInTransaction(
        token.depositAndApprove(
          spender,
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS,
          {
            from: owner,
            value: toWei(1)
          }
        ),
        "Deposit"
      );

      const finalBalance = await token.balanceOf(owner);
      finalBalance.should.be.bignumber.equal(toWei(1));
    });

    it("sets the allowance", async () => {
      await expectEventInTransaction(
        token.depositAndApprove(
          spender,
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS,
          {
            from: owner,
            value: toWei(1)
          }
        ),
        "Approval"
      );

      const allowance = await token.allowance(owner, spender);
      allowance.should.be.bignumber.equal(
        constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
      );

      const randomAllowance = await token.allowance(owner, randomUser);
      randomAllowance.should.be.bignumber.equal(0);
    });
  });

  describe("withdrawAndTransfer", () => {
    it("adjusts the balance and transfers to target", async () => {
      const initialBalance = await token.balanceOf(owner);
      initialBalance.should.be.bignumber.equal(0);

      await expectEventInTransaction(
        token.deposit({ from: owner, value: toWei(1) }),
        "Deposit"
      );

      await expectEventInTransaction(
        token.withdrawAndTransfer(toWei(1), randomUser, { from: owner }),
        "Withdrawal"
      );

      const ownerBalance = await token.balanceOf(owner);

      ownerBalance.should.be.bignumber.equal(0);
    });

    it("fails if the target is 0x0", async () => {
      const initialBalance = await token.balanceOf(owner);
      initialBalance.should.be.bignumber.equal(0);

      await expectEventInTransaction(
        token.deposit({ from: owner, value: toWei(1) }),
        "Deposit"
      );

      await expectThrow(
        token.withdrawAndTransfer(toWei(1), constants.ZERO_ADDRESS, {
          from: owner
        })
      );

      const ownerBalance = await token.balanceOf(owner);

      ownerBalance.should.be.bignumber.equal(toWei(1));
    });

    it("fails with insufficient balance", async () => {
      const initialBalance = await token.balanceOf(owner);
      initialBalance.should.be.bignumber.equal(0);

      await expectThrow(
        token.withdrawAndTransfer(toWei(1), randomUser, { from: owner })
      );
    });
  });
});
