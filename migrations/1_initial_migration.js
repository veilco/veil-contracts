const Migrations = artifacts.require("Migrations");

module.exports = function(deployer, _, accounts) {
  deployer.deploy(Migrations, {from: "0x5680ca2e3b4f8bc043aceb31837c89dba8bfba75"});
};
