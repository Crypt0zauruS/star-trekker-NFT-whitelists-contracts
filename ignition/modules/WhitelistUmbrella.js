const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const dAppAddress = "0x78b1792Fd8773D5cB9f601B7AbE50D1390440631";
const maxAddresses = 20;

module.exports = buildModule("WhitelistUmbrellaModule", (m) => {
  const dAppSigner = m.getParameter("dAppSigner", dAppAddress);
  const maxWhitelistedAddresses = m.getParameter(
    "maxWhitelistedAddresses",
    maxAddresses
  );
  const whitelistUmbrella = m.contract("WhitelistUmbrella", [
    maxWhitelistedAddresses,
    dAppSigner,
  ]);

  return { whitelistUmbrella };
});
