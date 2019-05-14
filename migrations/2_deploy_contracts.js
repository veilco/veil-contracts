const VeilEther = artifacts.require("VeilEther");
const VirtualAugurShareFactory = artifacts.require("VirtualAugurShareFactory");
const VeilCompleteSets = artifacts.require("VeilCompleteSets");
const AugurLiteCompleteSets = artifacts.require("AugurLiteCompleteSets");
const OracleBridge = artifacts.require("OracleBridge");

module.exports = function(deployer, network, accounts) {
  deployer.then(async () => {
    await deployer.deploy(VeilEther);
    await deployer.deploy(VirtualAugurShareFactory);
    await deployer.deploy(VeilCompleteSets);
    await deployer.deploy(AugurLiteCompleteSets);
    await deployer.deploy(OracleBridge);
  });
};
