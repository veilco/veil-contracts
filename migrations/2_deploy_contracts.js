const VeilEther = artifacts.require("VeilEther");

const ZeroExAddressByNetwork = {
  1: "0x2240dab907db71e64d3e0dba4800c83b5c502d4e",
  42: "0xf1ec01d6236d3cd881a0bf0130ea25fe4234003e"
};

module.exports = function(deployer, network, accounts) {
  console.log("Deploying Veil Ether...");

  const defaultSpenderAddress =
    ZeroExAddressByNetwork[deployer.network_id] || accounts[0];

  return deployer
    .deploy(VeilEther, defaultSpenderAddress)
    .then(() => {
      return VeilEther.deployed();
    })
    .then(() => {
      console.log("Deployment complete!");
    });
};
