pragma solidity 0.4.24;

import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { UnlimitedAllowanceToken } from "../UnlimitedAllowanceToken.sol";


/**
 * @title MintableTokenMock
 * @author Veil
 */
contract MintableTokenMock is UnlimitedAllowanceToken {
  using SafeMath for uint256;

  constructor () public { }

  function mint(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "Invalid address");

    totalSupply = totalSupply.add(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(address(0), _to, _value);
  }
}
