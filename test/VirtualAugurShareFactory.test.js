import expectEventInTransaction from "./utils/expectEvent";
import expectThrow from "./utils/expectThrow";
import { constants } from "./utils/constants";
import { advanceBlock } from "./utils/advanceToBlock";

const VirtualAugurShareFactory = artifacts.require("VirtualAugurShareFactory");
const MintableTokenMock = artifacts.require("MintableTokenMock");
const BigNumber = web3.BigNumber;
const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("VirtualAugurShareFactory", ([creator, spender]) => {
  let factory, token;

  beforeEach(async () => {
    token = await MintableTokenMock.new({ from: creator });
    factory = await VirtualAugurShareFactory.new({ from: creator });
    await advanceBlock();
  });

  describe("create", () => {
    it("succeds", async () => {
      expectEventInTransaction(
        await factory.create(token.address, spender),
        "TokenCreation"
      );

      const virtualToken = await factory.getVirtualToken(token.address);
      assert.notEqual(virtualToken, constants.ZERO_ADDRESS);
    });

    it("if a token is already processed, returns the existing address", async () => {
      expectEventInTransaction(
        await factory.create(token.address, spender),
        "TokenCreation"
      );

      const virtualToken = await factory.getVirtualToken(token.address);
      assert.notEqual(virtualToken, constants.ZERO_ADDRESS);

      await factory.create(token.address, spender);

      const newToken = await factory.getVirtualToken(token.address);
      assert.equal(virtualToken, newToken);
    });
  });

  describe("batchCreate", () => {
    it("succeds", async () => {
      const token2 = await MintableTokenMock.new({ from: creator });
      expectEventInTransaction(
        await factory.batchCreate(
          [token.address, token2.address],
          [spender, spender]
        ),
        "TokenCreation"
      );
    });

    it("fails if there is a mismatch of tokens and spenders", async () => {
      await expectThrow(
        factory.batchCreate([token.address], [spender, spender])
      );
    });
  });

  describe("getToken", () => {
    it("returns the 0x0 address if the token is not used", async () => {
      const newToken = await factory.getToken(creator);
      assert.equal(newToken, constants.ZERO_ADDRESS);
    });

    it("returns the correct address", async () => {
      expectEventInTransaction(
        await factory.create(token.address, spender),
        "TokenCreation"
      );

      const virtualToken = await factory.getVirtualToken(token.address);

      const newToken = await factory.getToken(virtualToken);
      assert.equal(newToken, token.address);
    });
  });

  describe("getVirtualToken", () => {
    it("returns the 0x0 address if the token is not used", async () => {
      const newToken = await factory.getVirtualToken(token.address);
      assert.equal(newToken, constants.ZERO_ADDRESS);
    });

    it("returns the correct address", async () => {
      expectEventInTransaction(
        await factory.create(token.address, spender),
        "TokenCreation"
      );

      const newToken = await factory.getVirtualToken(token.address);
      assert.notEqual(newToken, constants.ZERO_ADDRESS);
    });
  });
});
