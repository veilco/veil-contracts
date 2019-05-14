pragma solidity 0.4.24;

import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { VirtualAugurShare } from "./VirtualAugurShare.sol";
import { ICompleteSets } from "./ICompleteSets.sol";
import { IMarket } from "./IMarket.sol";


/**
 * @title AugurLiteCompleteSets
 * @author Veil
 *
 * Simple utility contract to simplify the process of buying complete sets from VeilAugur, wrapping
 * the complete sets in Virtual Augur Shares and transferring them to msg.sender.
 *
 * This contract is stateless, never holds funds, and can be swapped with another contract any time.
 */
contract AugurLiteCompleteSets {
  using SafeMath for uint256;

  event VeilAugurBuyCompleteSets(address indexed sender, uint256 amount);

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
   * Buys VeilAugur complete sets with Ether, wraps the complete set tokens in Virtual Augur Shares
   * and transfers them to msg.sender
   *
   * @param _augurContract       VeilAugur contract address
   * @param _token               Denomination token address
   * @param _augurCompleteSets   VeilAugur complete sets contract address
   * @param _augurMarket         VeilAugur market contract address
   * @param _virtualLongToken    Virtual Augur Share long token address
   * @param _virtualShortToken   Virtual Augur Share short token address
   * @param _amount              Amount of complete sets to buy
   */
  function buyCompleteSets(
    address _augurContract,
    address _token,
    address _augurCompleteSets,
    address _augurMarket,
    address _virtualLongToken,
    address _virtualShortToken,
    uint256 _amount
  )
    public
    returns (bool)
  {
    require(IMarket(_augurMarket).getDenominationToken() == _token, "Wrong type of token");

    if (IERC20(_token).allowance(this, _augurContract) != uint256(-1)) {
      require(IERC20(_token).approve(_augurContract, uint256(-1)), "Approval failed");
    }

    require(IERC20(_token).transferFrom(msg.sender, this, _amount.mul(IMarket(_augurMarket).getNumTicks())));
    ICompleteSets(_augurCompleteSets).publicBuyCompleteSets(_augurMarket, _amount);

    // Make sure VAS contracts can transfer Augur shares
    IERC20 augurLongToken = IERC20(IMarket(_augurMarket).getShareToken(1));
    IERC20 augurShortToken = IERC20(IMarket(_augurMarket).getShareToken(0));

    if (augurLongToken.allowance(this, _virtualLongToken) != uint256(-1)) {
      require(augurLongToken.approve(_virtualLongToken, uint256(-1)), "Long approval failed");
    }

    if (augurShortToken.allowance(this, _virtualShortToken) != uint256(-1)) {
      require(augurShortToken.approve(_virtualShortToken, uint256(-1)), "Short approval failed");
    }

    // Deposit and transfer individual shares
    VirtualAugurShare virtualLong = VirtualAugurShare(_virtualLongToken);
    VirtualAugurShare virtualShort = VirtualAugurShare(_virtualShortToken);

    require(virtualLong.depositAndTransfer(_amount, msg.sender), "VAS Long deposit and transfer failed");
    require(virtualShort.depositAndTransfer(_amount, msg.sender), "VAS Short deposit and transfer failed");

    emit VeilAugurBuyCompleteSets(msg.sender, _amount);
    return true;
  }
}
