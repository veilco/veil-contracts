pragma solidity >=0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import { UnlimitedAllowanceToken } from "./UnlimitedAllowanceToken.sol";


/**
 * @title VirtualAugurShare
 * @author Veil
 *
 * WETH-like token that wraps Augur ERC-20 shares and comes pre-approved for trading on 0x
 * The default spender is set to the 0x ERC20 Proxy contract to give unlimited allowance
 * without the need to unlock tokens. The underlying Augur ERC-20 share can be redeemed any time.
 * The contract implements the Ownable interface. If the token is set to address(0) upon creation,
 * it can be updated to an ERC-20 address by the owner. Once the token is set, nothing can change.
 */
contract VirtualAugurShare is UnlimitedAllowanceToken, Ownable {
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
  event SetToken(address indexed token);

  /* ============ Public Functions ============ */

  /**
   * @dev Fallback function
   */
  function() external {
    revert("Fallback function reverts");
  }

  modifier whenTokenIsSet {
    require(token != address(0), "Underlying token is not set");
    _;
  }

  modifier whenTokenIsNotSet {
    require(token == address(0), "Underlying token is already set");
    _;
  }

  modifier whenDefaultSpenderIsNotSet {
    require(defaultSpender == address(0), "Default spender is already set");
    _;
  }

  /**
   * Sets the underlying ERC-20 token of the VirtualAugurShare. Only callable by the owner when
   * when the token address(0)
   *
   * @param _token            Underlying ERC-20 token address to wrap
   */
  function setToken(address _token) public onlyOwner whenTokenIsNotSet returns (bool) {
    token = _token;
    emit SetToken(_token);
    return true;
  }

  /**
   * Sets the default spender (0x contract) of the VirtualAugurShare. Only callable by the owner when
   * when the default spender is not address(0)
   *
   * @param _defaultSpender            default spender address (0x contract)
   */
  function setDefaultSpender(address _defaultSpender) public onlyOwner whenDefaultSpenderIsNotSet returns (bool) {
    defaultSpender = _defaultSpender;
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1 and sets the spender allowance.
   * Only callable when token is not address(0)
   *
   * @param _deposit          Amount of tokens to be deposited
   * @param _spender          Spender address for the allowance
   * @param _allowance        Allowance amount
   */
  function depositAndApprove(uint256 _deposit, address _spender, uint256 _allowance)
    public
    whenTokenIsSet
    returns (bool)
  {
    deposit(_deposit);
    approve(_spender, _allowance);
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1, and transfers them to a target
   * address instead of msg.sender. Only callable when the token is not address(0)
   *
   * @param _amount           Amount of tokens to be deposited
   * @param _target           Address to send the tokens
   */
  function depositAndTransfer(uint256 _amount, address _target)
    public
    whenTokenIsSet
    returns (bool)
  {
    deposit(_amount);
    transfer(_target, _amount);
    return true;
  }

  /**
   * Buys tokens with the underlying token, exchanging them 1:1. Only callable when the token is
   * not address(0)
   *
   * @param _amount          Amount of tokens to be deposited
   */
  function deposit(uint256 _amount) public whenTokenIsSet returns (bool) {
    require(IERC20(token).transferFrom(msg.sender, address(this), _amount), "Token transfer unsuccessful");

    balances[msg.sender] = balances[msg.sender].add(_amount);
    totalSupply = totalSupply.add(_amount);
    emit Deposit(msg.sender, _amount);
    return true;
  }

  /**
   * Withdraw the underlying token, exchanging them 1:1. Only callable when the token is not
   * address(0)
   *
   * @param _amount          Amount of tokens to be withdrawn
   */
  function withdraw(uint256 _amount) public whenTokenIsSet returns (bool) {
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
    if (_spender == defaultSpender) {
      return uint256(-1);
    }
    return allowed[_owner][_spender];
  }
}
