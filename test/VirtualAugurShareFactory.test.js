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

contract("VirtualAugurShareFactory", ([creator, spender, randomUser]) => {
  let factory, token;

  beforeEach(async () => {
    token = await MintableTokenMock.new({ from: creator });
    factory = await VirtualAugurShareFactory.new({ from: creator });
    await advanceBlock();
  });

  describe("create", () => {
    it("succeds with random address", async () => {
      expectEventInTransaction(
        await factory.create(token.address, spender, { from: randomUser }),
        "TokenCreation"
      );
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
        factory.batchCreate([token.address], [spender, spender], {
          from: creator
        })
      );
    });
  });
});
