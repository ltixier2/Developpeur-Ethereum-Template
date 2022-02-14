pragma solidity 0.8.11;


contract getTime {

    function getCurrentTime() external view returns  (uint)  {
        return block.timestamp; 

    }
}
