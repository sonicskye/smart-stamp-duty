var SSDToken = artifacts.require("SmartStampDutyToken");
var SSDStorage = artifacts.require("SmartStampDutyStorage");

module.exports = function(deployer) {
  deployer.deploy(SSDToken);
  deployer.deploy(SSDStorage);
};
