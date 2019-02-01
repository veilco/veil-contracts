pragma solidity 0.4.24;

import { OwnableVirtualAugurShare } from "./OwnableVirtualAugurShare.sol";


/**
 * @title OwnableVirtualAugurShareFactory
 * @author Veil
 *
 * Token factory that creates new OwnableVirtualAugurShares
 */
contract OwnableVirtualAugurShareFactory {

  /* ============ Events ============ */

  event TokenCreation(address indexed token, address indexed virtualToken, address spender);

  /* ============ Constructor ============ */

  constructor() public { }

  /* ============ Public Functions ============ */

  /**
   * For a given token address and a default spender, creates a OwnableVirtualAugurShare
   *
   * @param _token            Underlying ERC-20 token address to wrap
   * @param _defaultSpender   This address will have unlimited allowance by default
   */
  function create(address _token, address _defaultSpender) public returns (address) {
    address virtualToken = new OwnableVirtualAugurShare(_token, _defaultSpender);
    OwnableVirtualAugurShare(virtualToken).transferOwnership(msg.sender);

    emit TokenCreation(_token, virtualToken, _defaultSpender);
    return virtualToken;
  }

  /**
   * Create but processed in batch
   *
   * @param _tokens           Array of underlying ERC-20 token address to wrap
   * @param _defaultSpenders  Array of addresses that will have unlimited allowance by default
   */
  function batchCreate(address[] _tokens, address[] _defaultSpenders) public returns (address[]) {
    require(_tokens.length == _defaultSpenders.length, "Mismatch of token and spender counts");

    address[] memory virtualTokens = new address[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      virtualTokens[i] = create(_tokens[i], _defaultSpenders[i]);
    }

    return virtualTokens;
  }
}
