pragma solidity 0.4.25;


/**
 * @title Migrations
 * @dev Standard migration file provided by Truffle
 */
contract Migrations {
  address public owner;
  uint public lastCompletedMigration;

  // CONSTRUCTOR

  constructor () public {
    owner = msg.sender;
  }

  // MODIFIERS

  modifier restricted() {
    if (msg.sender == owner)
      _;
  }

  // PUBLIC FUNCTIONS

  function setCompleted(uint completed) public restricted {
    lastCompletedMigration = completed;
  }

  function upgrade(address newAddress) public restricted {
    Migrations upgraded = Migrations(newAddress);
    upgraded.setCompleted(lastCompletedMigration);
  }
}
