pragma solidity ^0.5.12;
 // force usage of a single version of compiler and have the most recent one. 

contract Crowdsale {
   using SafeMath for uint256;
 
   address public owner; // the owner of the contract
   address public escrow; // wallet to collect raised ETH
   uint256 public savedBalance = 0; // Total amount raised in ETH
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   function Crowdsale(address _escrow) {
       owner = tx.origin;
       // a require that uses onlyOwner replace this. 
       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
   function() public {
       balances[msg.sender] += msg.value;
       savedBalance += msg.value;
       escrow.send(msg.value);
   }
  
   // refund investisor
   function withdrawPayments() public{
       address payee = msg.sender;
       uint256 payment = balances[payee];
 
       payee.send(payment);
 
       savedBalance -= payment;
       balances[payee] = 0;
       // to be sure that reentrency is not used set balance at the top of the function 
   }
}
