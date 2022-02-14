pragma solidity 0.8.11; 


contract Choice {

    mapping (address =>  uint) public usersChoice;

function setChoice(uint userChoice) external{
    usersChoice[msg.sender] = userChoice;

    }

}
