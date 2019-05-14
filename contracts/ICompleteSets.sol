pragma solidity 0.4.24;


/**
 * @title ICompleteSets
 * @author Veil
 *
 * Simplified Augur CompleteSets interface
 */
contract ICompleteSets {
  function publicBuyCompleteSets(address _market, uint256 _amount) external returns (bool);
  function publicBuyCompleteSetsWithCash(address _market, uint256 _amount) external returns (bool);
}
