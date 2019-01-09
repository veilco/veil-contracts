pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { UnlimitedAllowanceToken } from "./UnlimitedAllowanceToken.sol";


/**
 * @title VeilEther
 * @author Veil
 *
 * WETH-like token with the ability to deposit ETH and approve in a single transaction
 */
contract VeilEther is UnlimitedAllowanceToken {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Veil Ether"; // solium-disable-line uppercase
  string constant public symbol = "Veil ETH"; // solium-disable-line uppercase
  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /* ============ Events ============ */

  event Deposit(address indexed dest, uint256 amount);
  event Withdrawal(address indexed src, uint256 amount);

  /* ============ Constructor ============ */

  constructor () public { }

  /* ============ Public functions ============ */

  /**
   * @dev Fallback function can be used to buy tokens by proxying the call to deposit()
   */
  function() public payable {
    deposit();
  }

  /* ============ New functionality ============ */

  /**
   * Buys tokens with Ether, exchanging them 1:1 and sets the spender allowance
   *
   * @param _spender          Spender address for the allowance
   * @param _allowance        Allowance amount
   */
  function depositAndApprove(address _spender, uint256 _allowance) public payable returns (bool) {
    deposit();
    approve(_spender, _allowance);
    return true;
  }

  /**
   * Buys tokens with Ether, exchanging them 1:1, and transfers them to a target address instead of msg.sender
   *
   * @param _target           Address to send the tokens
   */
  function depositAndTransfer(address _target) public payable returns (bool) {
    deposit();
    transfer(_target, msg.value);
    return true;
  }

  /**
   * Withdraws from msg.sender's balance and transfers to a target address instead of msg.sender
   *
   * @param _amount           Amount to withdraw
   * @param _target           Address to send the withdrawn ETH
   */
  function withdrawAndTransfer(uint256 _amount, address _target) public returns (bool) {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");
    require(_target != address(0), "Invalid target address");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    _target.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
    return true;
  }

  /* ============ Standard WETH functionality ============ */

  function deposit() public payable returns (bool) {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    totalSupply = totalSupply.add(msg.value);
    emit Deposit(msg.sender, msg.value);
    return true;
  }

  function withdraw(uint256 _amount) public returns (bool) {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    msg.sender.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
    return true;
  }
}
