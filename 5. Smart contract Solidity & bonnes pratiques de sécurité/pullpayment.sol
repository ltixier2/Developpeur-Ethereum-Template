pragma solidity 0.8.9;
 
contract auction {
    address highestBidder;
    uint highestBid;
    mapping (address => uint) refunds; 
 
    function bid() payable public {
        require(msg.value >= highestBid);
 
        if (highestBidder != address(0)) {
            (bool success, ) = highestBidder.call{value:highestBid}("");
            require(success); // if this call consistently fails, no one else can bid
        }
 
       highestBidder = msg.sender;
       highestBid = msg.value;
    }

    function withdraw() external {
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0; 
        (bool success, ) = msg.sender.call{value:refund}("");
        require(success);
    }
}
