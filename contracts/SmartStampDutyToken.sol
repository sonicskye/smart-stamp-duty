pragma solidity ^0.4.24;

import './Ownable.sol';
import './ERC20Pausable.sol';

/**
 * @title Smart Stamp Duty Token
 * @dev ERC20 Tokens
 */
contract SmartStampDutyToken is Ownable, ERC20Pausable {

  string public constant name = "Smart Stamp Duty";
  string public constant symbol = "SSD";
  uint8 public constant decimals = 0;

  /**
   * @dev Initial supply will be  10 trillion or 10*10**12
   * @dev Each SSD represents 1 Rupiah, hence the total amount of SSD received represents tax money
   * @dev The number of available SSD can be increased further by mint function
   * @dev No decimal is required
   */ 
  uint256 public constant INITIAL_SUPPLY = 10*10**12 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    _mint(msg.sender, INITIAL_SUPPLY);
  }
}