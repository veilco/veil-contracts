const VeilEther = artifacts.require("VeilEther");
const VirtualAugurShareFactory = artifacts.require("VirtualAugurShareFactory");
const VeilCompleteSets = artifacts.require("VeilCompleteSets");

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(VeilEther);
    await deployer.deploy(VirtualAugurShareFactory);
    await deployer.deploy(VeilCompleteSets);
  });
};
