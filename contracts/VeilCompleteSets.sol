pragma solidity 0.4.24;

import { IERC20 } from "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import { VirtualAugurShare } from "./VirtualAugurShare.sol";
import { SafeMath } from "openzeppelin-solidity/contracts/math/SafeMath.sol";


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


/**
 * @title ICompleteSets
 * @author Veil
 *
 * Simplified Augur CompleteSets interface
 */
contract ICompleteSets {
  function publicBuyCompleteSetsWithCash(address _market, uint256 _amount) external returns (bool);
}


/**
 * @title IMarket
 * @author Veil
 *
 * Simplified Augur Market interface
 */
contract IMarket {
  function getNumTicks() public view returns (uint256);
  function getShareToken(uint256 _outcome) public view returns (address);
}


/**
 * @title VeilCompleteSets
 * @author Veil
 *
 * Simple contract to wrap the process of depositing Cash to Augur, buying complete sets
 * from Augur, wrapping the complete sets in Virtual Augur Shares and transferring to msg.sender.
 *
 * This contract is stateless, never holds funds, and can be swapped with another contract any time.
 */
contract VeilCompleteSets {
  using SafeMath for uint256;

  event VeilBuyCompleteSets(address indexed sender, uint256 amount);

  /* ============ Constructor ============ */

  constructor() public { }

  /* ============ Public Functions ============ */

  /**
   * @dev Fallback function
   */
  function() public {
    revert("Fallback function reverts");
  }

  function buyCompleteSets(
    address _augurContract,
    address _augurCash,
    address _augurCompleteSets,
    address _augurMarket,
    address _virtualLongToken,
    address _virtualShortToken,
    uint256 _amount
  )
    public
    payable
    returns (bool)
  {
    // Make sure the msg.value is the correct amount to prevent excess fund build-up in the contract
    require(_amount.mul(IMarket(_augurMarket).getNumTicks()) == msg.value, "Msg.value is incorrect");

    // Deposit Cash and buy complete sets
    if (ICash(_augurCash).allowance(this, _augurContract) != uint256(-1)) {
      require(ICash(_augurCash).approve(_augurContract, uint256(-1)), "Cash approval failed");
    }
    ICash(_augurCash).depositEther.value(msg.value)();
    ICompleteSets(_augurCompleteSets).publicBuyCompleteSetsWithCash(_augurMarket, _amount);

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

    // The next version of this will use depositAndTransfer
    require(virtualLong.deposit(_amount), "VAS Long deposit failed");
    require(virtualShort.deposit(_amount), "VAS Short deposit failed");
    require(virtualLong.transfer(msg.sender, _amount), "VAS Long transfer failed");
    require(virtualShort.transfer(msg.sender, _amount), "VAS Long transfer failed");

    emit VeilBuyCompleteSets(msg.sender, _amount);
    return true;
  }
}
