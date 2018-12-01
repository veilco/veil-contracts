pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { UnlimitedAllowanceToken } from "./UnlimitedAllowanceToken.sol";


/**
 * @title VirtualAugurShare
 * @author Veil
 */
contract VirtualAugurShare is UnlimitedAllowanceToken {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Virtual Augur Share"; // solium-disable-line uppercase
  string constant public symbol = "Virtual Augur Share"; // solium-disable-line uppercase
  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /* ============ State variables ============ */

  address public token;
  address public defaultSpender;

  /* ============ Events ============ */

  event Deposit(address indexed dest, uint256 amount);
  event Withdrawal(address indexed src, uint256 amount);

  /* ============ Constructor ============ */

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
    revert();
  }

  function deposit(uint256 _amount) public {
    require(IERC20(token).transferFrom(msg.sender, address(this), _amount));

    balances[msg.sender] = balances[msg.sender].add(_amount);
    totalSupply = totalSupply.add(_amount);
    emit Deposit(msg.sender, _amount);
  }

  function depositAndApprove(address _spender, uint256 _deposit, uint256 _allowance) public {
    deposit(_deposit);
    approve(_spender, _allowance);
  }

  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    require(IERC20(token).transfer(msg.sender, _amount));

    emit Withdrawal(msg.sender, _amount);
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    if (_spender == defaultSpender) return uint256(-1);
    return allowed[_owner][_spender];
  }
}
