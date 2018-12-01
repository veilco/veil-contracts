const VeilEther = artifacts.require("VeilEther");
const VirtualAugurShareFactory = artifacts.require("VirtualAugurShareFactory");

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(VeilEther);
    await deployer.deploy(VirtualAugurShareFactory);
  });
};
