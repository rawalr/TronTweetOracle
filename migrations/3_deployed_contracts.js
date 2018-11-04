var Vote = artifacts.require("predictionMarket");
module.exports = function(deployer) {
  deployer.deploy(Vote,'Clowns are scarier than spiders')
};
