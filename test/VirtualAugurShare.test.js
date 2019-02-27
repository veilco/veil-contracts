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
    let tokenIsSet, tokenIsNotSet, mintableToken;

    beforeEach(async () => {
      mintableToken = await MintableTokenMock.new({
        from: creator
      });
      tokenIsSet = await VirtualAugurShare.new(
        mintableToken.address,
        defaultSpender,
        { from: creator }
      );
      tokenIsNotSet = await VirtualAugurShare.new(
        constants.ZERO_ADDRESS,
        defaultSpender,
        { from: creator }
      );

      await advanceBlock();
    });

    describe("token metadata", () => {
      it("has a name", async () => {
        const name = await tokenIsNotSet.name();
        assert.equal(name, "Virtual Augur Share");
      });

      it("has a symbol", async () => {
        const symbol = await tokenIsNotSet.symbol();
        assert.equal(symbol, "VSHARE");
      });

      it("has 18 decimals", async () => {
        const decimals = await tokenIsNotSet.decimals();
        assert(decimals.eq(18));
      });
    });

    describe("setToken", () => {
      it("can only be called by the owner", async () => {
        const owner = await tokenIsNotSet.owner();
        const tokenAddress = await tokenIsNotSet.token();

        assert.equal(owner, creator);
        assert.equal(tokenAddress, constants.ZERO_ADDRESS);
        expectEventInTransaction(
          await tokenIsNotSet.setToken(mintableToken.address, {
            from: creator
          }),
          "SetToken"
        );
      });

      it("can't be called by non-owner", async () => {
        const owner = await tokenIsNotSet.owner();
        const tokenAddress = await tokenIsNotSet.token();

        assert.notEqual(owner, randomUser);
        assert.equal(tokenAddress, constants.ZERO_ADDRESS);

        await expectThrow(
          tokenIsNotSet.setToken(mintableToken.address, {
            from: randomUser
          })
        );
      });

      it("can only be called if the token is not set", async () => {
        const owner = await tokenIsSet.owner();
        const tokenAddress = await tokenIsSet.token();

        assert.equal(owner, creator);
        assert.notEqual(tokenAddress, constants.ZERO_ADDRESS);

        await expectThrow(
          tokenIsSet.setToken(mintableToken.address, {
            from: creator
          })
        );
      });
    });

    describe("allowance", () => {
      it("returns unlimited allowance for the default spender", async () => {
        const allowance = await tokenIsSet.allowance(
          randomUser,
          defaultSpender
        );
        allowance.should.be.bignumber.equal(
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
        );
      });

      it("returns regular allowance for other addresses", async () => {
        const allowance = await tokenIsSet.allowance(randomUser, creator);
        allowance.should.be.bignumber.equal(0);
      });
    });

    describe("deposit", () => {
      it("can call deposit if the token is set", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectEventInTransaction(
          tokenIsSet.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );
      });

      it("can't call deposit if the token is not set", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(
          tokenIsNotSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectThrow(
          tokenIsNotSet.deposit(toWei(1), {
            from: randomUser
          })
        );
      });
    });

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
        tokenIsSet.deposit(toWei(1), {
          from: randomUser
        })
      );
    });

    it("fails if the user doesn't have enough of the original token", async () => {
      const initialBalance = await mintableToken.balanceOf(randomUser);
      initialBalance.should.be.bignumber.equal(0);

      await mintAndApproveToken(tokenIsSet, mintableToken, creator, randomUser);

      await expectThrow(
        tokenIsSet.deposit(toWei(2), {
          from: randomUser
        })
      );
    });

    it("succeeds", async () => {
      const initialBalance = await mintableToken.balanceOf(randomUser);
      initialBalance.should.be.bignumber.equal(0);

      await mintAndApproveToken(tokenIsSet, mintableToken, creator, randomUser);

      await expectEventInTransaction(
        tokenIsSet.deposit(toWei(1), {
          from: randomUser
        }),
        "Deposit"
      );
    });

    describe("withdraw", () => {
      it("fails with insufficient balance", async () => {
        const initialBalance = await tokenIsSet.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await expectThrow(tokenIsSet.withdraw(toWei(1), { from: randomUser }));
      });

      it("succeeds", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectEventInTransaction(
          tokenIsSet.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        await expectEventInTransaction(
          tokenIsSet.withdraw(toWei(1), { from: randomUser }),
          "Withdrawal"
        );
      });
    });

    describe("transferFrom", () => {
      it("fails if the allowance is 0 and the spender is not the default spender", async () => {
        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectEventInTransaction(
          tokenIsSet.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        const allowance = await tokenIsSet.allowance(randomUser, spender);
        allowance.should.be.bignumber.equal(0);

        await expectThrow(
          tokenIsSet.transferFrom(randomUser, creator, toWei(1), {
            from: spender
          })
        );
      });

      it("succeeds if the spender is the default spender", async () => {
        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectEventInTransaction(
          tokenIsSet.deposit(toWei(1), {
            from: randomUser
          }),
          "Deposit"
        );

        const allowance = await tokenIsSet.allowance(
          randomUser,
          defaultSpender
        );
        allowance.should.be.bignumber.equal(
          constants.UNLIMITED_ALLOWANCE_IN_BASE_UNITS
        );

        await expectEventInTransaction(
          tokenIsSet.transferFrom(randomUser, creator, toWei(1), {
            from: defaultSpender
          }),
          "Transfer"
        );
      });
    });

    describe("depositAndTransfer", () => {
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
          tokenIsSet.depositAndTransfer(toWei(1), spender, {
            from: randomUser
          })
        );
      });

      it("fails if the user doesn't have enough of the original token", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectThrow(
          tokenIsSet.depositAndTransfer(toWei(2), spender, {
            from: randomUser
          })
        );
      });

      it("succeeds if deposit is successful", async () => {
        const initialBalance = await mintableToken.balanceOf(randomUser);
        initialBalance.should.be.bignumber.equal(0);

        const initialTokenBalanceSpender = await tokenIsSet.balanceOf(spender);
        initialTokenBalanceSpender.should.be.bignumber.equal(0);

        await mintAndApproveToken(
          tokenIsSet,
          mintableToken,
          creator,
          randomUser
        );

        await expectEventInTransaction(
          tokenIsSet.depositAndTransfer(toWei(1), spender, {
            from: randomUser
          }),
          "Deposit"
        );

        const finalBalance = await mintableToken.balanceOf(randomUser);
        finalBalance.should.be.bignumber.equal(0);

        const finalTokenBalanceSpender = await tokenIsSet.balanceOf(spender);
        finalTokenBalanceSpender.should.be.bignumber.equal(toWei(1));
      });
    });
  }
);
