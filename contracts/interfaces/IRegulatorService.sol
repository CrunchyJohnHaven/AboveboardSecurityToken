pragma solidity ^0.4.18;

/// @notice Standard interface for `RegulatorService`s

interface IRegulatorService {

  /**
   * @notice Triggered when storage address is replaced
   */
  event ReplaceStorage(address oldStorage, address newStorage);

  /*
   * @notice This method *MUST* be called by `RegulatedToken`s during `transfer()` and `transferFrom()`.
   *         The implementation *SHOULD* check whether or not a transfer can be approved.
   *
   * @dev    This method *MAY* call back to the token contract specified by `_token` for
   *         more information needed to enforce trade approval.
   *
   * @param  _from The address of the sender account
   * @param  _to The address of the receiver account
   * @param  _amount The quantity of the token to trade
   *
   * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation
   *               to assign meaning.
   */
  function check(address _from, address _to, uint256 _amount) public returns (uint8);
  
}
