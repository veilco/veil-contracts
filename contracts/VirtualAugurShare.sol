pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { UnlimitedAllowanceToken } from "./UnlimitedAllowanceToken.sol";


/**
 * @title VirtualAugurShare
 * @author Veil
 *
 * WETH-like token that wraps Augur ERC-20 shares and comes pre-approved for trading on 0x
 * The default spender is set to the 0x ERC20 Proxy contract to give unlimited allowance
 * without the need to unlock tokens. The underlying Augur ERC-20 share can be redeemed any time.
 */
contract VirtualAugurShare is UnlimitedAllowanceToken {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Virtual Augur Share"; // solium-disable-line uppercase
  string constant public symbol = "VSHARE"; // solium-disable-line uppercase
  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /* ============ State variables ============ */

  address public token;
  address public defaultSpender;

  /* ============ Events ============ */

  event Deposit(address indexed dest, uint256 amount);
  event Withdrawal(address indexed src, uint256 amount);

  /* ============ Constructor ============ */

  /**
   * Constructor function for VirtualAugurShare token
   *
   * @param _token            Underlying ERC-20 token address to wrap
   * @param _defaultSpender   This address will have unlimited allowance by default
   */
  constructor(address _token, address _defaultSpender) public {
    require(_token != address(0), "Invalid token address");
    require(_defaultSpender != address(0), "Invalid defaultSpender address");

    token = _token;
    defaultSpender = _defaultSpender;
  }

  /* ============ Public Functions ============ */

  /**
   * @dev Fallback function
   */
  function() public {
    revert("Fallback function reverts");
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1 and sets the spender allowance
   *
   * @param _deposit          Amount of tokens to be deposited
   * @param _spender          Spender address for the allowance
   * @param _allowance        Allowance amount
   */
  function depositAndApprove(uint256 _deposit, address _spender, uint256 _allowance) public returns (bool) {
    deposit(_deposit);
    approve(_spender, _allowance);
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1, and transfers them to a target
   * address instead of msg.sender
   *
   * @param _amount           Amount of tokens to be deposited
   * @param _target           Address to send the tokens
   */
  function depositAndTransfer(uint256 _amount, address _target) public returns (bool) {
    deposit(_amount);
    transfer(_target, _amount);
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1
   *
   * @param _amount          Amount of tokens to be deposited
   */
  function deposit(uint256 _amount) public returns (bool) {
    require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Token transfer unsuccessful");

    balances[msg.sender] = balances[msg.sender].add(_amount);
    totalSupply = totalSupply.add(_amount);
    emit Deposit(msg.sender, _amount);
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1
   *
   * @param _amount          Amount of tokens to be deposited
   */
  function withdraw(uint256 _amount) public returns (bool) {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    require(IERC20(token).transfer(msg.sender, _amount), "Token transfer failed");

    emit Withdrawal(msg.sender, _amount);
    return true;
  }

  /**
   * Updates the standard allowance method to return unlimited allowance for the default spender
   *
   * @param _owner           Address that owns the funds
   * @param _spender         Address that will spend the funds
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    if (_spender == defaultSpender)
      return uint256(-1);
    return allowed[_owner][_spender];
  }
}
