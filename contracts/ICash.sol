pragma solidity 0.4.24;


/**
 * @title ICash
 * @author Veil
 *
 * Simplified Augur Cash interface
 */
contract ICash {
  function depositEther() external payable returns(bool);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function approve(address _spender, uint256 _value) public returns (bool);
}
