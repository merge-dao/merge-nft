const ConvertLib = artifacts.require("ConvertLib");
const MetaCoin = artifacts.require("MetaCoin");
const Rarity = artifacts.require("Rarity");;
const RarityEnhance = artifacts.require("RarityEnhance");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
  deployer.deploy(Rarity);
  deployer.deploy(RarityEnhance);
};
