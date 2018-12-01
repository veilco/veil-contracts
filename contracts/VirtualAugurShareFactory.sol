pragma solidity 0.4.24;

import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import { VirtualAugurShare } from "./VirtualAugurShare.sol";


/**
 * @title VirtualAugurShareFactory
 * @author Veil
 */
contract VirtualAugurShareFactory is Ownable {

  /* ============ State variables ============ */
  mapping (address => address) public  tokenToVirtualToken;
  mapping (address => address) public  virtualTokenToToken;

  /* ============ Constructor ============ */

  constructor() public { }

  /* ============ Public/External Functions ============ */

  function create(address _token, address _defaultSpender)
    public
    onlyOwner
    returns (address)
  {
    if (tokenToVirtualToken[_token] != address(0)) return tokenToVirtualToken[_token];
    address virtualToken = new VirtualAugurShare(_token, _defaultSpender);
    tokenToVirtualToken[_token] = virtualToken;
    virtualTokenToToken[virtualToken] = _token;

    return virtualToken;
  }

  function batchCreate(address[] _tokens, address[] _defaultSpenders)
    public
    onlyOwner
    returns (address[])
  {
    require(_tokens.length == _defaultSpenders.length, "Mismatch of token and spender counts");

    address[] memory virtualTokens = new address[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      virtualTokens[i] = create(_tokens[i], _defaultSpenders[i]);
    }

    return virtualTokens;
  }

  function getVirtualToken(address _token) public view returns (address) {
    return tokenToVirtualToken[_token];
  }

  function getToken(address _virtualToken) public view returns (address) {
    return virtualTokenToToken[_virtualToken];
  }
}
