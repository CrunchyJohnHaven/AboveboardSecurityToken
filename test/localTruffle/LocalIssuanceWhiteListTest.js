let IssuanceWhiteList = artifacts.require('contracts/IssuanceWhiteList.sol');

contract('IssuanceWhiteList', function(accounts) {

    let issuanceWhiteList;

    beforeEach(async () => {

        issuanceWhiteList = await IssuanceWhiteList.new({from: accounts[0]});

    });

    it("Test agent - qualifier addition/removal", async function() {
        
        await issuanceWhiteList.setAgent(accounts[0]);
        await issuanceWhiteList.addQualifier(accounts[0]);
        await issuanceWhiteList.removeQualifier(accounts[0]);

    });

    it("Get list of qualifiers", async function() {

        await issuanceWhiteList.addQualifier(accounts[0]);
        await issuanceWhiteList.addQualifier(accounts[1]);

        let l = await issuanceWhiteList.getQualifiers();
        assert.equal(l[0], accounts[0]);
        assert.equal(l[1], accounts[1]);

        await issuanceWhiteList.removeQualifier(accounts[0]);

        l = await issuanceWhiteList.getQualifiers();
        assert.equal(l[0], '0x0000000000000000000000000000000000000000');
        assert.equal(l[1], accounts[1]);

    });
});