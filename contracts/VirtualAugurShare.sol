pragma solidity 0.4.24;

import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title VirtualAugurShare
 * @author Veil
 */
contract VirtualAugurShare is IERC20 {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Virtual Augur Share"; // solium-disable-line uppercase
  string constant public symbol = "Virtual Augur Share"; // solium-disable-line uppercase
  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /* ============ State variables ============ */

  address public token;
  address public defaultSpender;
  uint256 public totalSupply;
  mapping (address => uint256) public  balances;
  mapping (address => mapping (address => uint256)) public allowed;
  mapping (address => mapping (address => bool)) public allowanceSetByUser;

  /* ============ Events ============ */

  event Approval(address indexed src, address indexed spender, uint256 amount);
  event Transfer(address indexed src, address indexed dest, uint256 amount);
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

  function depositAndApprove(address _spender, uint256 _depositAmount, uint256 _allowance) public {
    deposit(_depositAmount);
    approve(_spender, _allowance);
  }

  function deposit(uint256 _amount) public {
    require(IERC20(token).transferFrom(msg.sender, address(this), _amount));

    balances[msg.sender] = balances[msg.sender].add(_amount);
    totalSupply = totalSupply.add(_amount);
    emit Deposit(msg.sender, _amount);
  }

  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    require(IERC20(token).transfer(msg.sender, _amount));

    emit Withdrawal(msg.sender, _amount);
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    if (!allowanceSetByUser[_owner][_spender] && _spender == defaultSpender) return uint256(-1);
    return allowed[_owner][_spender];
  }

  /* ============ WETH-like Functionality ============ */

  function approve(address _spender, uint256 _amount) public returns (bool) {
    allowed[msg.sender][_spender] = _amount;
    allowanceSetByUser[msg.sender][_spender] = true;
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

  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply;
  }
}
