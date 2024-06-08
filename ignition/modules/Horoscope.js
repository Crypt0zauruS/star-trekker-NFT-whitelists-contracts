const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const dAppAddress = "0x78b1792Fd8773D5cB9f601B7AbE50D1390440631";

module.exports = buildModule("HoroscopeNFTv3Module", (m) => {
  const dAppSigner = m.getParameter("dAppSigner", dAppAddress);

  const horoscopeNFTv3 = m.contract("HoroscopeNFTv3", [dAppSigner]);

  return { horoscopeNFTv3 };
});
