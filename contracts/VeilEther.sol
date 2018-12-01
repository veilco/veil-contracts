pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { UnlimitedAllowanceToken } from "./UnlimitedAllowanceToken.sol";


/**
 * @title VeilEther
 * @author Veil
 */
contract VeilEther is UnlimitedAllowanceToken {
  using SafeMath for uint256;

  /* ============ Constants ============ */

  string constant public name = "Veil Ether"; // solium-disable-line uppercase
  string constant public symbol = "Veil Ether"; // solium-disable-line uppercase
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

  function deposit() public payable {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    totalSupply = totalSupply.add(msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  function depositAndApprove(address _spender, uint256 _amount) public payable {
    deposit();
    approve(_spender, _amount);
  }

  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    msg.sender.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
  }

  function withdrawAndTransfer(uint256 _amount, address _target) public {
    require(balances[msg.sender] >= _amount, "Insufficient user balance");
    require(_target != address(0), "Invalid target address");

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    _target.transfer(_amount);

    emit Withdrawal(msg.sender, _amount);
  }
}
