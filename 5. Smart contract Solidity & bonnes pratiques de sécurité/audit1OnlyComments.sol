pragma solidity ^0.5.12;
 // force usage of a single version of compiler and have the most recent one. 

contract Crowdsale {
   //using SafeMath for uint256;
  // useless
   address public owner; // the owner of the contract
   address payable public  escrow; // wallet to collect raised ETH added payable.
   uint256 public savedBalance = 0; // Total amount raised in ETH
   mapping (address => uint256) public balances; // Balances in incoming Ether
 
   // Initialization
   
   
   constructor  Crowdsale(address _escrow) {
       //replaced function by constructor
       owner = msg.sender;
       //tx.origin should be replaced by msg.sender 

       // add address of the specific contract
       escrow = _escrow;
   }
  
   // function to receive ETH
    receive()  payable external {
       // set the function payable to recieve ethers
       
       balances[msg.sender] += msg.value;
       savedBalance += msg.value;
       escrow.send(msg.value);
   }
  
   // refund investisor
   function withdrawPayments() public{
       address payee = msg.sender;
       uint256 payment = balances[payee];
       balances[payee] = 0;
       payee.send(payment);
 
       savedBalance -= payment;
       
       // need to be sure that reentrency is not used set balance at the top of the function set the balance at 0 before sending payments
       
   }
}
