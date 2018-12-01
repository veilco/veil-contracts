import expectEventInTransaction from "./utils/expectEvent";
import expectThrow from "./utils/expectThrow";
import toWei from "./utils/toWei";
import { constants } from "./utils/constants";
import { advanceBlock } from "./utils/advanceToBlock";

const VirtualAugurShare = artifacts.require("VirtualAugurShare");
const MintableTokenMock = artifacts.require("MintableTokenMock");
const BigNumber = web3.BigNumber;
const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const mintAndApproveToken = async (virtualToken, token, creator, address) => {
  const initialAllowance = await token.allowance(address, virtualToken.address);
  initialAllowance.should.be.bignumber.equal(0);

  await token.mint(address, toWei(1), {
    from: creator
  });

  await token.approve(
    virtualToken.address,
    constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS,
    { from: address }
  );

  const newAllowance = await token.allowance(address, virtualToken.address);
  newAllowance.should.be.bignumber.equal(
    constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
  );
};

contract(
  "VirtualAugurShare",
  ([creator, spender, randomUser, defaultSpender]) => {
    let token, mintableToken;

    beforeEach(async () => {
      mintableToken = await MintableTokenMock.new({
        from: creator
      });
      token = await VirtualAugurShare.new(
        mintableToken.address,
        defaultSpender,
        { from: creator }
      );
      await advanceBlock();
    });

    describe("token metadata", () => {
      it("has a name", async () => {
        const name = await token.name();
        assert.equal(name, "Virtual Augur Share");
      });

      it("has a symbol", async () => {
        const symbol = await token.symbol();
        assert.equal(symbol, "Virtual Augur Share");
      });

      it("has 18 decimals", async () => {
        const decimals = await token.decimals();
        assert(decimals.eq(18));
      });
    });

    describe("allowance", () => {
      it("returns unlimited allowance for the default spender", async () => {
        const allowance = await token.allowance(randomUser, defaultSpender);
        allowance.should.be.bignumber.equal(
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
        );
      });

      it("returns regular allowance for other addresses", async () => {
        const allowance = await token.allowance(randomUser, creator);
        allowance.should.be.bignumber.equal(0);
      });
    });

    describe("deposit", () => {
      it("fails if the allowance of the original token is 0", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await expectEventInTransaction(
          mintableToken.mint(randomUser, toWei(1), {
            from: creator
          }),
          "Transfer"
        );
        const newBalance = await mintableToken.balanceOf(randomUser);
        newBalance.should.be.bignumber.equal(toWei(1));

        await expectThrow(
          token.deposit(toWei(1), {
            from: randomUser
          })
        );
      });

      it("fails if the user doesn't have enough of the original token", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(token, mintableToken, creator, randomUser);

        await expectThrow(
          token.deposit(toWei(2), {
            from: randomUser
          })
        );
      });

      it("succeeds", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(token, mintableToken, creator, randomUser);

        await expectEventInTransaction(
          token.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );
      });
    });

    describe("withdraw", () => {
      it("fails with insufficient balance", async () => {
        const initialBalance = await token.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await expectThrow(token.withdraw(toWei(1), { from: randomUser }));
      });

      it("succeeds", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(token, mintableToken, creator, randomUser);

        await expectEventInTransaction(
          token.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        await expectEventInTransaction(
          token.withdraw(toWei(1), { from: randomUser }),
          "Withdrawal"
        );
      });
    });

    describe("transferFrom", () => {
      it("fails if the allowance is 0 and the spender is not the default spender", async () => {
        await mintAndApproveToken(token, mintableToken, creator, randomUser);

        await expectEventInTransaction(
          token.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        const allowance = await token.allowance(randomUser, spender);
        allowance.should.be.bignumber.equal(0);

        await expectThrow(
          token.transferFrom(randomUser, creator, toWei(1), {
            from: spender
          })
        );
      });

      it("succeeds if the spender is the default spender", async () => {
        await mintAndApproveToken(token, mintableToken, creator, randomUser);

        await expectEventInTransaction(
          token.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        const allowance = await token.allowance(randomUser, defaultSpender);
        allowance.should.be.bignumber.equal(
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
        );

        await expectEventInTransaction(
          token.transferFrom(randomUser, creator, toWei(1), {
            from: defaultSpender
          }),
          "Transfer"
        );
      });
    });
  }
);
