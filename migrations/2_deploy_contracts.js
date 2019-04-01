const VeilEther = artifacts.require("VeilEther");
const VirtualAugurShareFactory = artifacts.require("VirtualAugurShareFactory");
const VeilCompleteSets = artifacts.require("VeilCompleteSets");
const VirtualAugurShare = artifacts.require("VirtualAugurShare")

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(VirtualAugurShare, {from: "0xb142bee56c35df2906f013edfffe901c0b2502b9"});//vanity contract address
    await deployer.deploy(VeilEther, {from: "0x5680ca2e3b4f8bc043aceb31837c89dba8bfba75"});
    await deployer.deploy(VirtualAugurShareFactory, {from: "0x5680ca2e3b4f8bc043aceb31837c89dba8bfba75"});
    await deployer.deploy(VeilCompleteSets, {from: "0x5680ca2e3b4f8bc043aceb31837c89dba8bfba75"});
  });
};
