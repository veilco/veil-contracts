pragma solidity 0.4.24;

import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import { VirtualAugurShare } from "./VirtualAugurShare.sol";


/**
 * @title VirtualAugurShareFactory
 * @author Veil
 *
 * Token factory that creates new VirtualAugurShares and keeps track of token-virtual token mappings
 */
contract VirtualAugurShareFactory is Ownable {

  /* ============ State variables ============ */
  mapping (address => address) public  tokenToVirtualToken;
  mapping (address => address) public  virtualTokenToToken;
  mapping (address => bool) public whitelisted;

  /* ============ Events ============ */

  event TokenCreation(address indexed token, address indexed virtualToken, address spender);

  /* ============ Constructor ============ */

  /**
   * Constructor function that whitelists the contract creator
   */
  constructor() public {
    whitelisted[msg.sender] = true;
  }

  /* ============ Modifiers ============ */

  /**
   * @dev Throws if called by any account that is not whitelisted
   */
  modifier onlyWhitelisted() {
    require(whitelisted[msg.sender], "Address is not whitelisted");
    _;
  }

  /* ============ Public Functions ============ */

  /**
   * For a given token address and a default spender, creates a VirtualAugurShare
   * If the token is already processed through this factory, it will return the virtual share address
   *
   * @param _token            Underlying ERC-20 token address to wrap
   * @param _defaultSpender   This address will have unlimited allowance by default
   */
  function create(address _token, address _defaultSpender)
    public
    onlyWhitelisted
    returns (address)
  {
    if (tokenToVirtualToken[_token] != address(0)) return tokenToVirtualToken[_token];
    address virtualToken = new VirtualAugurShare(_token, _defaultSpender);
    tokenToVirtualToken[_token] = virtualToken;
    virtualTokenToToken[virtualToken] = _token;

    emit TokenCreation(_token, virtualToken, _defaultSpender);
    return virtualToken;
  }

  /**
   * Create but processed in batch
   *
   * @param _tokens           Array of underlying ERC-20 token address to wrap
   * @param _defaultSpenders  Array of addresses that will have unlimited allowance by default
   */
  function batchCreate(address[] _tokens, address[] _defaultSpenders)
    public
    onlyWhitelisted
    returns (address[])
  {
    require(_tokens.length == _defaultSpenders.length, "Mismatch of token and spender counts");

    address[] memory virtualTokens = new address[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      virtualTokens[i] = create(_tokens[i], _defaultSpenders[i]);
    }

    return virtualTokens;
  }

  /**
   * Adds new address to the whitelist. Only callable by the owner.
   *
   * @param _newAddress       Address to be whitelisted
   */
  function whitelistAddress(address _newAddress) public onlyOwner returns (bool) {
    whitelisted[_newAddress] = true;
    return true;
  }

  /**
   * Return the virtual token address for a given token address
   *
   * @param _token    Address of the underlying token
   */
  function getVirtualToken(address _token) public view returns (address) {
    return tokenToVirtualToken[_token];
  }

  /**
   * Return the token address for a given virtual token address
   *
   * @param _virtualToken    Address of the virtual token
   */
  function getToken(address _virtualToken) public view returns (address) {
    return virtualTokenToToken[_virtualToken];
  }
}
