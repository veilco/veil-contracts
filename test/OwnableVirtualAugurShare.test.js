import expectEventInTransaction from "./utils/expectEvent";
import expectThrow from "./utils/expectThrow";
import toWei from "./utils/toWei";
import { constants } from "./utils/constants";
import { advanceBlock } from "./utils/advanceToBlock";

const OwnableVirtualAugurShare = artifacts.require("OwnableVirtualAugurShare");
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
  "OwnableVirtualAugurShare",
  ([creator, randomUser, defaultSpender]) => {
    let tokenIsSet, tokenIsNotSet, mintableToken;

    beforeEach(async () => {
      mintableToken = await MintableTokenMock.new({
        from: creator
      });
      tokenIsSet = await OwnableVirtualAugurShare.new(
        mintableToken.address,
        defaultSpender,
        { from: creator }
      );
      tokenIsNotSet = await OwnableVirtualAugurShare.new(
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
  }
);
