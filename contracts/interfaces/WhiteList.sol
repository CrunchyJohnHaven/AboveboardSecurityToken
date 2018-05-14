pragma solidity ^0.4.18;

/**
 * @title WhiteList
 * @dev Interface for WhiteList contracts
 */
contract WhiteList {

  /// @dev Event raised when a new member is added
  event MemberAdded(address member);

  /// @dev Event raised when a member is removed
  event MemberRemoved(address member);

  /// @dev Verifies that a member is already in the member mapping
  /// @param member Address of a member that we check to see if it's in the whitelist
  function verify(address member) public constant returns (bool);

  /// @dev Adds a member in the member mapping
  /// @param member Address of a member that is added to the whitelist
  function add(address member) public returns (bool);

  /// @dev Adds members in the member mapping
  /// @param members Addresses of members that are added to the whitelist
  function addBuyers(address[] members) public returns (bool);

  /// @dev Deletes a member from the member mapping
  /// @param member Address of a member that is deleted from the whitelist
  function remove(address member) public returns (bool);

}
