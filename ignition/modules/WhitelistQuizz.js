const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const dAppAddress = "0x78b1792Fd8773D5cB9f601B7AbE50D1390440631";
const maxAddresses = 80;
const whitelistUmbrellaCorp = "0x03C82eef6FaE9c14B224e056c127a4155F47D404";

module.exports = buildModule("WhitelistQuizzModule", (m) => {
  const dAppSigner = m.getParameter("dAppSigner", dAppAddress);
  const maxWhitelistedAddresses = m.getParameter(
    "maxWhitelistedAddresses",
    maxAddresses
  );
  const whitelistUmbrellaContract = m.getParameter(
    "whitelistUmbrellaContract",
    whitelistUmbrellaCorp
  );
  const whitelistQuizz = m.contract("WhitelistQuizz", [
    maxWhitelistedAddresses,
    dAppSigner,
    whitelistUmbrellaContract,
  ]);

  return { whitelistQuizz };
});
