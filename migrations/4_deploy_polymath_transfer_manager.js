const IssuanceWhiteList = artifacts.require("./IssuanceWhiteList.sol")
const SettingsStorage = artifacts.require("./SettingsStorage.sol")
const TransferManager = artifacts.require("./polymath/AboveboardTransferManager.sol")

const deployPolymath = true

module.exports = async (deployer, network, accounts) => {
  if (!deployPolymath) { return }

  await deployer.deploy(IssuanceWhiteList)
  await deployer.deploy(SettingsStorage)
  await deployer.deploy(TransferManager, '0xFec990b9aa412d93cD12E61d7dfC3f63676e7ea2', '0x0DFb0511E9e28B643a9B01A684724048821992D4', SettingsStorage.address, { gas: 9000000 })

  const whitelist = await IssuanceWhiteList.deployed()
  await whitelist.setWhitelistType('RegS')

  const storage = await SettingsStorage.deployed()
  await storage.addWhitelist(IssuanceWhiteList.address)

  await storage.setIssuer(accounts[0])
  await storage.allowNewShareholders(true)
}
