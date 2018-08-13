const IssuanceWhiteList = artifacts.require('contracts/SecureIssuanceWhiteList.sol')
const RegulatedToken = artifacts.require('./RegulatedToken.sol')
const ServiceRegistry = artifacts.require('./ServiceRegistry.sol')
const RegulatorService = artifacts.require('./AboveboardRegDSWhitelistRegulatorService.sol')
const SettingsStorage = artifacts.require('./SettingsStorage.sol')

contract('SecureIssuanceWhiteList', accounts => {
  let issuanceWhiteList
  let storage
  let regulator
  let token1
  let token2

  const owner = accounts[0]
  const hacker = accounts[3]

  beforeEach(async () => {
    storage = await SettingsStorage.new({ from: owner })

    regulator = await RegulatorService.new(storage.address, { from: owner })

    const registry = await ServiceRegistry.new(regulator.address)

    token1 = await RegulatedToken.new(registry.address, 'Test', 'TEST')

    token2 = await RegulatedToken.new(registry.address, 'Test', 'TEST')

    issuanceWhiteList = await IssuanceWhiteList.new({from: owner})
  })

  it('Set whitelist type', async () => {
    let w = await issuanceWhiteList.setWhitelistType('QIB')
    assert.equal(w.logs[0].event, 'WhitelistTypeSet')
  })

  it('Get list of verified tokens, add tokens, remove tokens', async () => {
    await issuanceWhiteList.addToken(token1.address)
    await issuanceWhiteList.addToken(token2.address)

    let l = await issuanceWhiteList.getVerifiedTokens()
    assert.equal(l[0], token1.address)
    assert.equal(l[1], token2.address)

    await issuanceWhiteList.removeToken(token1.address)

    l = await issuanceWhiteList.getVerifiedTokens()
    assert.equal(l[0], '0x0000000000000000000000000000000000000000')
    assert.equal(l[1], token2.address)
  })

  it('verify', async () => {
    await issuanceWhiteList.addToken(token1.address)
    await issuanceWhiteList.addToken(token2.address)

    const l = await issuanceWhiteList.verify(owner, { from: owner })
    assert.equal(l, true)
  })
})
