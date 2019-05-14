pragma solidity 0.4.24;

import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract IMarket {
  function resolve(uint256[] _payouts, bool _invalid) public returns (bool);
}

/**
 * @title OracleBridge
 * @author Veil
 *
 * Simple utility contract to resolve markets on AugurLite. Market resolver can be set by the owner.
 *
 * The resolve() method can only be called by a specific market resolver address. If the market
 * resolver address is not set, the default resolver is the owner of the contract.
 */
contract OracleBridge is Ownable {

  /* ============ Constants ============ */

  address private constant NULL_ADDRESS = address(0);

  /* ============ Events ============ */

  event MarketResolved(address market, address resolver, uint256[] payouts, bool invalid);
  event MarketResolverSet(address market, address resolver);

  mapping(address => address) public marketsToResolvers;

  /* ============ Constructor ============ */

  constructor() public { }

  /* ============ Public Functions ============ */

  /**
   * @dev Fallback function
   */
  function() public {
    revert("Fallback function reverts");
  }

  /**
   * Resolves the market on VeilAugur. Only callable by the market resolver
   *
   * @param _market           Market contract address
   * @param _payouts          Payout array per market outcome
   * @param _invalid          Invalid boolean
   */
  function resolve(address _market, uint256[] _payouts, bool _invalid) public returns (bool) {
    require(msg.sender == getMarketResolver(_market), "Msg.sender is not the market resolver");
    require(IMarket(_market).resolve(_payouts, _invalid), "Market resolution failed");

    emit MarketResolved(_market, msg.sender, _payouts, _invalid);
    return true;
  }

  /**
   * Sets the market address to resolver address mapping, if it's not set. Only callable by the owner
   *
   * @param _market           Market contract address
   * @param _resolver         Resolver address
   */
  function setMarketResolver(address _market, address _resolver) public onlyOwner returns (bool) {
    require(marketsToResolvers[_market] == NULL_ADDRESS, "Market resolver is already set");

    marketsToResolvers[_market] = _resolver;
    emit MarketResolverSet(_market, _resolver);
    return true;
  }

  /**
   * Returns the resolver for the given market. The default is the contract owner
   *
   * @param _market           Market contract address
   */
  function getMarketResolver(address _market) public view returns (address) {
    if (marketsToResolvers[_market] != NULL_ADDRESS) {
      return marketsToResolvers[_market];
    }
    return owner();
  }
}
