pragma solidity >=0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


/**
 * @title UnlimitedAllowanceToken
 * @author Veil
 *
 * Standard UnlimitedAllowanceToken implementation: https://etherscan.io/address/0x2956356cd2a2bf3202f771f50d3d14a367b48070#code
 * The contract is adjusted to compile with solc 0.4.24
 * The transfer method is simplified by updating the allowance check in transferFrom
 */
contract UnlimitedAllowanceToken is IERC20 {
  using SafeMath for uint256;

  /* ============ State variables ============ */

  uint256 public supply;
  mapping (address => uint256) public  balances;
  mapping (address => mapping (address => uint256)) public allowed;

  /* ============ Events ============ */

  event Approval(address indexed src, address indexed spender, uint256 amount);
  event Transfer(address indexed src, address indexed dest, uint256 amount);

  /* ============ Constructor ============ */

  constructor () public { }

  /* ============ Public functions ============ */

  function approve(address _spender, uint256 _amount) public returns (bool) {
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  function transfer(address _dest, uint256 _amount) public returns (bool) {
    return transferFrom(msg.sender, _dest, _amount);
  }

  function transferFrom(address _src, address _dest, uint256 _amount) public returns (bool) {
    require(balances[_src] >= _amount, "Insufficient user balance");

    if (_src != msg.sender && allowance(_src, msg.sender) != uint256(-1)) {
      require(allowance(_src, msg.sender) >= _amount, "Insufficient user allowance");
      allowed[_src][msg.sender] = allowed[_src][msg.sender].sub(_amount);
    }

    balances[_src] = balances[_src].sub(_amount);
    balances[_dest] = balances[_dest].add(_amount);

    emit Transfer(_src, _dest, _amount);

    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function totalSupply() public view returns (uint256) {
    return supply;
  }
}
