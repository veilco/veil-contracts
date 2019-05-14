pragma solidity 0.4.24;


/**
 * @title IMarket
 * @author Veil
 *
 * Simplified Augur Market interface
 */
contract IMarket {
  function getNumTicks() public view returns (uint256);
  function getShareToken(uint256 _outcome) public view returns (address);
  function getDenominationToken() public view returns (address);
}
