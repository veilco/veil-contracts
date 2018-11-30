pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


/**
 * @title VeilEther
 * @author Veil
 * @dev This is an extension of WETH with the ability to deposit ETH and approve in one transaction
 */
contract VeilEther is IERC20 {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Veil Ether"; // solium-disable-line uppercase
  string constant public symbol = "Veil Ether"; // solium-disable-line uppercase
  uint256 constant public decimals = 18; // solium-disable-line uppercase

  /* ============ State variables ============ */

  uint256 public totalSupply;
  mapping (address => uint256) public  balances;
  mapping (address => mapping (address => uint256)) public allowed;

  /* ============ Events ============ */

  event Approval(address indexed src, address indexed spender, uint256 amount);
  event Transfer(address indexed src, address indexed dest, uint256 amount);
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

  /**
   * @dev depositAndApprove method that also sets the default spender to have unlimited allowance
   */
  function depositAndApprove(address _spender, uint256 _amount) public payable {
    deposit();
    approve(_spender, _amount);
  }

  /**
   * @dev Adjusts the msg.sender balance and transfers the amount to the target address
   */
  function withdrawAndTransfer(uint256 _amount, address _target) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");
    require(_target != address(0), "Invalid target address");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    _target.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
  }

  /* ============ WETH Functionality ============ */

  function deposit() public payable {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    totalSupply = totalSupply.add(msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    msg.sender.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
  }

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

    if (_src != msg.sender && allowed[_src][msg.sender] != uint256(-1)) {
      require(allowed[_src][msg.sender] >= _amount, "Insufficient user allowance");
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
    return totalSupply;
  }
}
