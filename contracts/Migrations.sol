pragma solidity >=0.4.24;


/**
 * @title Migrations
 * @author Veil
 *
 * Standard migration file provided by Truffle
 */
contract Migrations {
  address public owner;
  uint public lastCompletedMigration;

  /* ============ Constructor ============ */

  constructor () public {
    owner = msg.sender;
  }

  /* ============ Modifiers ============ */

  modifier restricted() {
    if (msg.sender == owner)
      _;
  }

  /* ============ Public functions ============ */

  function setCompleted(uint completed) public restricted {
    lastCompletedMigration = completed;
  }

  function upgrade(address newAddress) public restricted {
    Migrations upgraded = Migrations(newAddress);
    upgraded.setCompleted(lastCompletedMigration);
  }
}
