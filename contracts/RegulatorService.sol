pragma solidity ^0.4.18;

import "./zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./zeppelin-solidity/contracts/token/ERC20/BasicToken.sol";
import "./interfaces/WhiteList.sol";
import "./interfaces/IRegulatorService.sol";

/// @notice Standard interface for `RegulatorService`s
contract RegulatorService is IRegulatorService, Ownable {

  struct Settings {

    /**
     * @dev Toggle for locking/unlocking trades at a token level.
     *      The default behavior of the zero memory state for locking will be unlocked.
     */
    bool locked;

    /**
     * @dev Toggle for allowing/disallowing fractional token trades at a token level.
     *      The default state when this contract is created `false` (or no partial
     *      transfers allowed).
     */
    bool partialTransfers;

    /// @dev Toggle for allowing/disallowing new shareholders
    bool newShareholdersAllowed;

    /// @dev Address of Regulation D Whitelist
    address regDWhitelist;

    /// @dev Issuer of the token
    address issuer;

    /// @dev Initial offering end date
    uint256 initialOfferEndDate;
  }

  /// @dev Messaging address
  string messagingAddress;

  /// @dev Array of whitelists
  WhiteList[] whitelists;

  /// @notice Permissions that allow/disallow token trades on a per token level
  mapping(address => Settings) settings;

  // @dev Check success code
  uint8 constant private CHECK_SUCCESS = 0;

  // @dev Check error reason: Token is locked
  uint8 constant private CHECK_ELOCKED = 1;

  // @dev Check error reason: Token can not trade partial amounts
  uint8 constant private CHECK_EDIVIS = 2;

  // @dev Check error reason: Sender is not allowed to send the token
  uint8 constant private CHECK_ESEND = 3;

  // @dev Check error reason: Receiver is not allowed to receive the token
  uint8 constant private CHECK_ERECV = 4;

  // @dev Check error reason: Transfer before initial offering end date
  uint8 constant private CHECK_ERREGD = 5;

  // @dev Check error reason: New shareholders are not allowed
  uint8 constant private CHECK_ERALLOW = 6;

  /**
   * @notice Locks the ability to trade a token
   *
   * @dev    This method can only be called by this contract's owner
   *
   * @param  _token The address of the token to lock
   */
  function setLocked(address _token, bool _locked) onlyOwner public {
    settings[_token].locked = _locked;
    LogLockSet(_token, _locked);
  }

  /**
   * @notice Allows the ability to trade a fraction of a token
   *
   * @dev    This method can only be called by this contract's owner
   *
   * @param  _token The address of the token to allow partial transfers
   */
  function setPartialTransfers(address _token, bool _enabled) onlyOwner public {
   settings[_token].partialTransfers = _enabled;

   LogPartialTransferSet(_token, _enabled);
  }

  /*
   * @notice This method *MUST* be called by `RegulatedToken`s during `transfer()` and `transferFrom()`.
   *         The implementation *SHOULD* check whether or not a transfer can be approved.
   *
   * @dev    This method *MAY* call back to the token contract specified by `_token` for
   *         more information needed to enforce trade approval.
   *
   * @param  _token The address of the token to be transfered
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount The quantity of the token to trade
   *
   * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation
   *               to assign meaning.
   */
  function check(address _token, address _from, address _to, uint256 _amount) public returns (uint8) {
    if (settings[_token].locked) {
      return CHECK_ELOCKED;
    }

    // if newShareholdersAllowed is not enabled, the transfer will only succeed if the buyer already has tokens
    if (!settings[_token].newShareholdersAllowed && BasicToken(_token).balanceOf(_to) == 0) {
      return CHECK_ERALLOW;
    }

    bool f;
    address wlFrom;
    (f, wlFrom) = isWhiteListed(_from);
    if (!f) {
      return CHECK_ESEND;
    }

    bool t;
    address wlTo;
    (t,wlTo) = isWhiteListed(_to);
    if (!t) {
      return CHECK_ERECV;
    }

    // sender or receiver is under Regulation D, Non-US investors can trade at any time
    if ((wlFrom == settings[_token].regDWhitelist || wlTo == settings[_token].regDWhitelist)
      && now < settings[_token].initialOfferEndDate
      && _from != settings[_token].issuer            // only issuer can send to US investors first year
      && _to != settings[_token].issuer) {           // US investors cannot sell these shares in the first year, except to the issuer
      return CHECK_ERREGD;
    }

    if (!settings[_token].partialTransfers && _amount % _wholeToken(_token) != 0) {
      return CHECK_EDIVIS;
    }

    return CHECK_SUCCESS;
  }

  /**
   * @notice Retrieves the whole token value from a token that this `RegulatorService` manages
   *
   * @param  _token The token address of the managed token
   *
   * @return The uint256 value that represents a single whole token
   */
  function _wholeToken(address _token) view private returns (uint256) {
    return uint256(10)**DetailedERC20(_token).decimals();
  }

    /**
   * @notice Check if address is indeed in one of the whitelists
   *
   * @param _address Buyer to be added to whitelist
   *
   * @return True if buyer is added to whitelist, otherwise false
   */
  function isWhiteListed(address _address) private returns (bool, address) {
    for (uint256 i = 0; i < whitelists.length; i++) {
      if (whitelists[i].verify(_address))
        return (true, whitelists[i]);
    }
    return (false, address(0));
  }
}
