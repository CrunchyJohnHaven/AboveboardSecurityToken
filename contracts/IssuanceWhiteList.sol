pragma solidity ^0.4.18;

import "./interfaces/IIssuanceWhiteList.sol";
import "./zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title IssuanceWhiteList
 * @dev WhiteList for an AboveBoard issued token. Owner is the issuer.
 */
contract IssuanceWhiteList is IIssuanceWhiteList, Ownable {

  address agent;
  mapping(address => bool) members;
  mapping(address => bool) qualifiers;
  address[] qualifiersAddress;
  mapping(address => uint256) qualifiersIndex;

  modifier onlyAgentOrOwner() {
    require(msg.sender == owner || msg.sender == agent);
    _;
  }

  function setAgent(address _agent) onlyOwner public {

    agent = _agent;
    NewAgentAssigned(_agent);
    
  }

  function addQualifier(address _qualifier) onlyAgentOrOwner public {

    qualifiers[_qualifier] = true;
    uint id = qualifiersAddress.length;
    qualifiersIndex[_qualifier] = id;
    qualifiersAddress.push(_qualifier);
    QualifierAdded(_qualifier);

  }

  function removeQualifier(address _qualifier) onlyAgentOrOwner public {

    qualifiers[_qualifier] = false;
    uint id = qualifiersIndex[_qualifier];
    delete qualifiersAddress[id];
    QualifierRemoved(_qualifier);

  }

  function add(address _buyer) public returns (bool) {

    // make only executable by owner, agent, and qualifiers
    bool isQualifier = qualifiers[msg.sender];

    // require that the caller is the owner of the contract, the agent or one of the qualifiers
    require(msg.sender == owner || msg.sender == agent || isQualifier);

    members[_buyer] = true;

    MemberAdded(_buyer);

  }

  function remove(address _buyer) public returns (bool) {

    // make only executable by owner, agent, and qualifiers
    bool isQualifier = qualifiers[msg.sender];

    // require that the caller is the owner of the contract, the agent or one of the qualifiers
    require(msg.sender == owner || msg.sender == agent || isQualifier);

    members[_buyer] = false;
    MemberRemoved(_buyer);

  }

  function verify(address _buyer) public constant returns (bool) {

    return members[_buyer] == true;

  }

  function getOwner() onlyAgentOrOwner constant public returns (address) {
    return owner;
  }

  function getQualifiers() onlyAgentOrOwner constant public returns (address[]) {
    return qualifiersAddress;
  }
}
