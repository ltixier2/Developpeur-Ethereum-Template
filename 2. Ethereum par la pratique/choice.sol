pragma solidity 0.8.11; 


contract Choice {

    mapping (address =>  uint) public usersChoice;

function setChoice(uint _userChoice) external{
    usersChoice[msg.sender] = _userChoice;

    }

}
