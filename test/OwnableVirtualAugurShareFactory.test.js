import expectEventInTransaction from "./utils/expectEvent";
import expectThrow from "./utils/expectThrow";
import { constants } from "./utils/constants";
import { advanceBlock } from "./utils/advanceToBlock";

const OwnableVirtualAugurShareFactory = artifacts.require(
  "OwnableVirtualAugurShareFactory"
);
const OwnableVirtualAugurShare = artifacts.require("OwnableVirtualAugurShare");
const BigNumber = web3.BigNumber;
const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

contract("OwnableVirtualAugurShareFactory", ([creator, spender]) => {
  let factory;

  beforeEach(async () => {
    factory = await OwnableVirtualAugurShareFactory.new({ from: creator });
    await advanceBlock();
  });

  describe("create", () => {
    it("transfers ownership of the OwnableVirtualAugurShare to the msg.sender", async () => {
      const txn = await factory.create(constants.ZERO_ADDRESS, spender, {
        from: creator
      });

      expectEventInTransaction(txn, "TokenCreation");

      const event = txn.logs.find(e => e.event === "TokenCreation");
      const virtualTokenAddress = event.args.virtualToken;
      const tokenOwner = await OwnableVirtualAugurShare.at(
        virtualTokenAddress
      ).owner();

      assert.equal(tokenOwner, creator);
    });
  });
});
